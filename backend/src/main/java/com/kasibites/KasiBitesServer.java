import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;

import java.io.*;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

public class KasiBitesServer {
    // Thread-safe list acting as our order store
    private static final List<Map<String, Object>> orders = new CopyOnWriteArrayList<>();

    public static void main(String[] args) throws IOException {
        int port = 8081;
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        
        // Endpoints
        server.createContext("/api/orders", new OrdersHandler());
        server.createContext("/webhook/whatsapp", new TwilioWebhookHandler());
        
        server.setExecutor(null);
        System.out.println("🚀 Kasi Bites Server started on port " + port);
        server.start();
    }

    private static void addCorsHeaders(HttpExchange exchange) {
        exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
        exchange.getResponseHeaders().add("Access-Control-Allow-Methods", "GET, PUT, POST, OPTIONS");
        exchange.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type");
    }

    static class OrdersHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            addCorsHeaders(exchange);
            
            if ("OPTIONS".equalsIgnoreCase(exchange.getRequestMethod())) {
                exchange.sendResponseHeaders(204, -1);
                return;
            }

            String path = exchange.getRequestURI().getPath();
            
            if ("GET".equalsIgnoreCase(exchange.getRequestMethod()) && path.equals("/api/orders")) {
                String jsonResponse = toJsonArray(orders);
                byte[] responseBytes = jsonResponse.getBytes(StandardCharsets.UTF_8);
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, responseBytes.length);
                OutputStream os = exchange.getResponseBody();
                os.write(responseBytes);
                os.close();
            } 
            else if ("PUT".equalsIgnoreCase(exchange.getRequestMethod()) && path.matches("/api/orders/.+/status")) {
                String[] parts = path.split("/");
                String orderId = parts[3];
                
                InputStreamReader isr = new InputStreamReader(exchange.getRequestBody(), StandardCharsets.UTF_8);
                BufferedReader reader = new BufferedReader(isr);
                StringBuilder body = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    body.append(line);
                }

                String newStatus = "PENDING";
                if (body.toString().contains("PREPARING")) newStatus = "PREPARING";
                if (body.toString().contains("COMPLETED")) newStatus = "COMPLETED";

                for (Map<String, Object> order : orders) {
                    if (order.get("id").equals(orderId)) {
                        order.put("status", newStatus);
                        break;
                    }
                }

                String resp = "{\"status\":\"success\"}";
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, resp.getBytes().length);
                OutputStream os = exchange.getResponseBody();
                os.write(resp.getBytes());
                os.close();
            } else {
                exchange.sendResponseHeaders(404, -1);
            }
        }
    }

    static class TwilioWebhookHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            addCorsHeaders(exchange);

            if (!"POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                exchange.sendResponseHeaders(405, -1);
                return;
            }

            InputStreamReader isr = new InputStreamReader(exchange.getRequestBody(), StandardCharsets.UTF_8);
            BufferedReader reader = new BufferedReader(isr);
            StringBuilder body = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }

            String rawBody = body.toString();
            String customerPhone = extractFormParam(rawBody, "From").replace("whatsapp:", "");
            String messageBody = java.net.URLDecoder.decode(extractFormParam(rawBody, "Body"), StandardCharsets.UTF_8);

            String orderId = "ORD-" + (new Random().nextInt(900) + 100);
            Map<String, Object> newOrder = new HashMap<>();
            newOrder.put("id", orderId);
            newOrder.put("customerName", "WhatsApp User");
            newOrder.put("customerPhone", customerPhone.isEmpty() ? "+27820000000" : customerPhone);
            newOrder.put("status", "PENDING");
            newOrder.put("timestamp", Instant.now().toString());

            List<Map<String, Object>> items = new ArrayList<>();
            Map<String, Object> item = new HashMap<>();
            item.put("name", messageBody.isEmpty() ? "Standard Kota" : messageBody);
            item.put("quantity", 1);
            items.add(item);
            newOrder.put("items", items);

            orders.add(0, newOrder);

            String twiml = "<Response><Message>Your order (" + orderId + ") has been received by Kasi Bites! 🍳</Message></Response>";
            exchange.getResponseHeaders().set("Content-Type", "text/xml");
            exchange.sendResponseHeaders(200, twiml.getBytes().length);
            OutputStream os = exchange.getResponseBody();
            os.write(twiml.getBytes());
            os.close();
            
            System.out.println("📲 New WhatsApp Order parsed and added: " + orderId + " -> " + messageBody);
        }
    }

    private static String toJsonArray(List<Map<String, Object>> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            sb.append(mapToJson(list.get(i)));
            if (i < list.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    private static String mapToJson(Map<String, Object> map) {
        StringBuilder sb = new StringBuilder("{");
        int idx = 0;
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            sb.append("\"").append(entry.getKey()).append("\":");
            Object val = entry.getValue();
            if (val instanceof List) {
                sb.append("[");
                List<?> innerList = (List<?>) val;
                for (int j = 0; j < innerList.size(); j++) {
                    sb.append(mapToJson((Map<String, Object>) innerList.get(j)));
                    if (j < innerList.size() - 1) sb.append(",");
                }
                sb.append("]");
            } else {
                sb.append("\"").append(val.toString()).append("\"");
            }
            if (++idx < map.size()) sb.append(",");
        }
        sb.append("}");
        return sb.toString();
    }

    private static String extractFormParam(String formData, String paramName) {
        for (String pair : formData.split("&")) {
            String[] kv = pair.split("=");
            if (kv.length == 2 && kv[0].equals(paramName)) {
                return kv[1];
            }
        }
        return "";
    }
}