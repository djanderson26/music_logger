import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_logger_app/core/constants/api_constants.dart';

void main() {
  test('ApiConstants reads values from dotenv', () {
    dotenv.loadFromString(
      envString: 'LASTFM_API_KEY=abc123\nGENIUS_ACCESS_TOKEN=token456',
    );

    expect(ApiConstants.lastFmKey, 'abc123');
    expect(ApiConstants.geniusAccessToken, 'token456');
  });
}