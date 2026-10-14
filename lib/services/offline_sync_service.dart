import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'database.dart';
import 'sync.dart';

/// Persistent outbox used by features whose server endpoint is not connected yet.
/// Backend only needs to register an uploader for the feature; reports are already
/// retained locally and will never be lost while offline.
class OfflineSyncJob {
  const OfflineSyncJob({
    required this.id,
    required this.feature,
    required this.localId,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final String feature;
  final String localId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'feature': feature,
        'localId': localId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OfflineSyncJob.fromJson(Map<String, dynamic> json) => OfflineSyncJob(
        id: '${json['id']}',
        feature: '${json['feature']}',
        localId: '${json['localId']}',
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        createdAt: DateTime.parse('${json['createdAt']}'),
      );
}

class OfflineSyncState {
  const OfflineSyncState({required this.isOnline, required this.pendingCount});
  final bool isOnline;
  final int pendingCount;
}

class OfflineSyncService {
  OfflineSyncService._();
  static final instance = OfflineSyncService._();
  static const _legacyOutboxKey = 'offline_sync_outbox_v1';

  final ValueNotifier<OfflineSyncState> state =
      ValueNotifier(const OfflineSyncState(isOnline: true, pendingCount: 0));
  final _db = DatabaseService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _syncing = false;

  Future<void> init() async {
    await _migrateLegacyOutbox();
    final connectivity = await Connectivity().checkConnectivity();
    await _setConnection(connectivity);
    _connectivitySubscription ??= Connectivity().onConnectivityChanged.listen(
          (results) => _setConnection(results),
        );
  }

  Future<void> _setConnection(List<ConnectivityResult> results) async {
    final online = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
    state.value = OfflineSyncState(
      isOnline: online,
      pendingCount: state.value.pendingCount,
    );
    await refresh();
    if (online) unawaited(syncNow());
  }

  Future<List<OfflineSyncJob>> _jobs() async {
    try {
      final rows = await _db.rawQuery(
          'select id, feature, local_id, payload, created_at from offline_sync_jobs order by created_at asc');
      return rows
          .map((row) => OfflineSyncJob(
                id: '${row['id']}',
                feature: '${row['feature']}',
                localId: '${row['local_id']}',
                payload: Map<String, dynamic>.from(
                    jsonDecode('${row['payload']}') as Map),
                createdAt: DateTime.parse('${row['created_at']}'),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> enqueue({
    required String feature,
    required String localId,
    required Map<String, dynamic> payload,
  }) async {
    final job = OfflineSyncJob(
      id: '$feature-$localId',
      feature: feature,
      localId: localId,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await _db.insert('offline_sync_jobs', {
      'id': job.id,
      'feature': job.feature,
      'local_id': job.localId,
      'payload': jsonEncode(job.payload),
      'created_at': job.createdAt.toIso8601String(),
    });
    await refresh();
    if (state.value.isOnline) {
      unawaited(syncNow());
    }
  }

  Future<void> _migrateLegacyOutbox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_legacyOutboxKey);
    if (raw == null) return;
    try {
      for (final data in jsonDecode(raw) as List) {
        final job =
            OfflineSyncJob.fromJson(Map<String, dynamic>.from(data as Map));
        await _db.insert('offline_sync_jobs', {
          'id': job.id,
          'feature': job.feature,
          'local_id': job.localId,
          'payload': jsonEncode(job.payload),
          'created_at': job.createdAt.toIso8601String(),
        });
      }
      await prefs.remove(_legacyOutboxKey);
    } catch (_) {
      // Leave old data untouched if it cannot be read.
    }
  }

  Future<bool> isPending(String feature, String localId) async =>
      (await _jobs())
          .any((job) => job.feature == feature && job.localId == localId);

  Future<void> refresh() async {
    var pending = (await _jobs()).length;
    for (final name in const [
      'inspection',
      'hazard',
      'coaching',
      'k3',
      'observation',
      'p2h',
      'p5m',
      'safety'
    ]) {
      try {
        final rows = await _db
            .rawQuery('select id from ${name}_trans where sync_id is null');
        pending += rows.length;
      } catch (_) {
        // A table may not be present in an older local database.
      }
    }
    state.value =
        OfflineSyncState(isOnline: state.value.isOnline, pendingCount: pending);
  }

  /// Syncs all legacy reports supported by the current API. Jobs remain queued
  /// until their feature-specific backend uploader is registered.
  Future<void> syncNow() async {
    if (_syncing || !state.value.isOnline || ApiService().getToken.isEmpty) {
      return;
    }
    _syncing = true;
    try {
      final api = ApiService();
      for (final name in const [
        'inspection',
        'hazard',
        'coaching',
        'k3',
        'observation',
        'p2h',
        'p5m',
        'safety'
      ]) {
        try {
          final rows = await _db
              .rawQuery('select id from ${name}_trans where sync_id is null');
          for (final row in rows) {
            await syncTran(_db, api, name, row['id'] as int);
          }
        } catch (_) {}
      }
    } finally {
      _syncing = false;
      await refresh();
    }
  }
}
