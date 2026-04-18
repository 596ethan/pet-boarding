package com.petboarding.server;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class PetBoardingApiTests {

  private static final String TOKEN = "demo-token-admin";
  private static final Pattern ID_PATTERN = Pattern.compile("\"id\":(\\d+)");

  @LocalServerPort
  private int port;

  private final HttpClient httpClient = HttpClient.newHttpClient();

  @Test
  @DisplayName("API should run the MVP workflow from login to completed history")
  void apiShouldRunMvpWorkflowFromLoginToCompletedHistory() throws Exception {
    HttpResponse<String> login = post("/api/auth/login", "{\"username\":\"admin\",\"password\":\"123456\"}", false);
    assertThat(login.statusCode()).isEqualTo(200);
    assertThat(login.body()).contains("\"success\":true", "\"token\":\"" + TOKEN + "\"");

    Long ownerId = extractId(postOk("/api/owners", "{\"name\":\"Api Owner\",\"phone\":\"13800018888\",\"remark\":\"\"}"));
    Long petId = extractId(postOk("/api/pets", "{\"ownerId\":" + ownerId + ",\"name\":\"Api Pet\",\"type\":\"Dog\",\"breed\":\"Poodle\",\"age\":2,\"weight\":5.6,\"temperament\":\"Calm\"}"));
    Long orderId = extractId(postOk("/api/orders", "{\"ownerId\":" + ownerId + ",\"petId\":" + petId + ",\"remark\":\"API order\"}"));

    HttpResponse<String> checkIn = post("/api/orders/" + orderId + "/check-in", "{\"roomId\":2}", true);
    assertThat(checkIn.statusCode()).isEqualTo(200);
    assertThat(checkIn.body()).contains("\"status\":\"CHECKED_IN\"", "\"roomId\":2");

    HttpResponse<String> care = post("/api/care-records", "{\"orderId\":" + orderId + ",\"type\":\"FEEDING\",\"content\":\"Dinner completed\"}", true);
    assertThat(care.statusCode()).isEqualTo(200);
    assertThat(care.body()).contains("\"type\":\"FEEDING\"");

    HttpResponse<String> checkout = post("/api/orders/" + orderId + "/checkout", "{}", true);
    assertThat(checkout.statusCode()).isEqualTo(200);
    assertThat(checkout.body()).contains("\"status\":\"COMPLETED\"");

    HttpResponse<String> rejectedCare = post("/api/care-records", "{\"orderId\":" + orderId + ",\"type\":\"NOTE\",\"content\":\"After checkout\"}", true);
    assertThat(rejectedCare.statusCode()).isEqualTo(400);
    assertThat(rejectedCare.body()).contains("\"success\":false");

    HttpResponse<String> history = get("/api/orders?status=COMPLETED");
    assertThat(history.statusCode()).isEqualTo(200);
    assertThat(history.body()).contains("\"status\":\"COMPLETED\"", "\"id\":" + orderId);

    HttpResponse<String> metrics = get("/api/dashboard/metrics");
    assertThat(metrics.statusCode()).isEqualTo(200);
    assertThat(metrics.body()).contains("\"availableRooms\"");
  }

  private HttpResponse<String> postOk(String path, String body) throws IOException, InterruptedException {
    HttpResponse<String> response = post(path, body, true);
    assertThat(response.statusCode()).isEqualTo(200);
    assertThat(response.body()).contains("\"success\":true");
    return response;
  }

  private HttpResponse<String> post(String path, String body, boolean auth) throws IOException, InterruptedException {
    HttpRequest.Builder builder = HttpRequest.newBuilder(URI.create(baseUrl() + path))
        .header("Content-Type", "application/json")
        .POST(HttpRequest.BodyPublishers.ofString(body));
    if (auth) {
      builder.header("Authorization", "Bearer " + TOKEN);
    }
    return httpClient.send(builder.build(), HttpResponse.BodyHandlers.ofString());
  }

  private HttpResponse<String> get(String path) throws IOException, InterruptedException {
    HttpRequest request = HttpRequest.newBuilder(URI.create(baseUrl() + path))
        .header("Authorization", "Bearer " + TOKEN)
        .GET()
        .build();
    return httpClient.send(request, HttpResponse.BodyHandlers.ofString());
  }

  private Long extractId(HttpResponse<String> response) {
    Matcher matcher = ID_PATTERN.matcher(response.body());
    assertThat(matcher.find()).isTrue();
    return Long.parseLong(matcher.group(1));
  }

  private String baseUrl() {
    return "http://localhost:" + port;
  }
}
