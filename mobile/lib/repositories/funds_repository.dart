import '../core/network/api_client.dart';
import '../models/fund.dart';

class FundsRepository {
  final ApiClient apiClient;

  FundsRepository(this.apiClient);

  Future<List<Fund>> getFunds() async {
    final response = await apiClient.get('/funds');

    final funds = response['funds'] as List;

    return funds.map((fund) => Fund.fromJson(fund)).toList();
  }
}
