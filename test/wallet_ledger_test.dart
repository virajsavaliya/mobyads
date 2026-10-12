import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/network/api_client.dart';
import 'package:mobyads/core/storage/secure_storage_service.dart';
import 'package:mobyads/features/wallet/controllers/wallet_controller.dart';
import 'package:mobyads/features/wallet/models/transaction_model.dart';
import 'package:mobyads/features/wallet/services/wallet_service.dart';

class FakeStorage extends SecureStorageService {
  @override
  Future<String?> getToken() async => null;
}

class FakeApi extends ApiClient {
  final Map<String, dynamic>? wallet;
  final List<Map<String, dynamic>> txns;
  final bool fail;
  FakeApi({this.wallet, this.txns = const [], this.fail = false})
      : super(dio: Dio(), secureStorage: FakeStorage());

  @override
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    if (fail) throw DioException(requestOptions: RequestOptions(path: path));
    if (path.contains('transactions')) {
      return Response<T>(
        requestOptions: RequestOptions(path: path),
        data: {'transactions': txns} as T,
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: wallet as T?,
    );
  }
}

void main() {
  test('server ledger applied with txn mapping', () async {
    final api = FakeApi(
      wallet: {
        'available': 20.40,
        'pending': 3.20,
        'total_earned': 81.25,
        'total_withdrawn': 57.65,
        'currency': 'INR',
      },
      txns: [
        {
          'id': 't1',
          'source_type': 'MCQ',
          'source_id': 'q1',
          'amount': 1.5,
          'currency': 'INR',
          'status': 'AVAILABLE',
        },
        {
          'id': 't2',
          'source_type': 'WITHDRAWAL',
          'source_id': 'w1',
          'amount': 10.0,
          'currency': 'INR',
          'status': 'WITHDRAWN',
        },
      ],
    );
    final c = WalletController(service: WalletService(api));
    await c.refreshFromServer();
    expect(c.state.availableBalance, 20.40);
    expect(c.state.pendingBalance, 3.20);
    expect(c.state.transactions.length, 2);
    expect(c.state.transactions.first.type, TransactionType.quizReward);
    expect(c.state.transactions.first.status, TransactionStatus.available);
    expect(c.state.transactions.last.isCredit, false);
    expect(c.loadedFromServer, true);
  });

  test('offline fallback keeps zero balances', () async {
    final c = WalletController(service: WalletService(FakeApi(fail: true)));
    final before = c.state.availableBalance;
    await c.refresh(); // refresh() catches DioException internally
    expect(c.state.availableBalance, before);
    expect(c.state.availableBalance, 0);
    expect(c.state.transactions, isEmpty);
    expect(c.loadedFromServer, false);
  });
}
