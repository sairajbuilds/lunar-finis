import '../core/network/api_client.dart';
import '../models/fund.dart';

class BasketRepository {
  final ApiClient apiClient;

  BasketRepository(this.apiClient);

  Future<List<Fund>> getBasket() async {
    final response = await apiClient.get('/basket');

    final funds = response['funds'] as List;

    return funds.map((fund) => Fund.fromJson(fund)).toList();
  }

  Future<void> addFund(String fundId) async {
    await apiClient.post('/basket', body: {'fundId': fundId});
  }

  Future<void> removeFund(String fundId) async {
    await apiClient.delete('/basket/$fundId');
  }
}
