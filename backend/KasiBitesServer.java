package com.kasibites;

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
    private static final List> orders = new CopyOnWriteArrayList<>();

    public static void main(String[] args) throws IOException {
        int port = 8082;
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        
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

    private static String readRequestBody(HttpExchange exchange) throws IOException {
        try (InputStream is = exchange.getRequestBody();
             ByteArrayOutputStream result = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[1024];
            int length;
            while ((length = is.read(buffer)) != -1) {
                result.write(buffer, 0, length);
            }
            return result.toString(StandardCharsets.UTF_8);
        }
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
            
            if ("GET".equalsIgnoreCase(exchange.getRequestMethod()) && (path.equals("/api/orders") || path.equals("/api/orders/"))) {
                String jsonResponse = toJsonArray(orders);
                byte[] responseBytes = jsonResponse.getBytes(StandardCharsets.UTF_8);
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, responseBytes.length);
                OutputStream os = exchange.getResponseBody();
                os.write(responseBytes);
                os.close();
            } 
            else if ("POST".equalsIgnoreCase(exchange.getRequestMethod()) && (path.equals("/api/orders") || path.equals("/api/orders/"))) {
                String rawBody = readRequestBody(exchange);
                
                String orderId = "ORD-" + (new Random().nextInt(900) + 100);
                String customerName = extractJsonField(rawBody, "customerName");
                if (customerName.isEmpty()) customerName = "Mobile User";
                
                String customerPhone = extractJsonField(rawBody, "customerPhone");
                if (customerPhone.isEmpty()) customerPhone = "+27820000000";
                
                String itemName = extractJsonField(rawBody, "item");
                if (itemName.isEmpty()) itemName = extractJsonField(rawBody, "name");
                if (itemName.isEmpty()) itemName = "Standard Kota";

                Map<String, Object> newOrder = new HashMap<>();
                newOrder.put("id", orderId);
                newOrder.put("customerName", customerName);
                newOrder.put("customerPhone", customerPhone);
                newOrder.put("status", "PENDING");
                newOrder.put("timestamp", Instant.now().toString());

                List> items = new ArrayList<>();
                Map<String, Object> item = new HashMap<>();
                item.put("name", itemName);
                item.put("quantity", 1);
                items.add(item);
                newOrder.put("items", items);

                orders.add(0, newOrder);

                String resp = "{\"status\":\"success\",\"orderId\":\"" + orderId + "\"}";
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, resp.getBytes(StandardCharsets.UTF_8).length);
                OutputStream os = exchange.getResponseBody();
                os.write(resp.getBytes(StandardCharsets.UTF_8));
                os.close();

                System.out.println("🛒 New Mobile Order created: " + orderId + " -> " + itemName);
            }
            else if ("PUT".equalsIgnoreCase(exchange.getRequestMethod()) && path.matches("/api/orders/.+/status")) {
                String[] parts = path.split("/");
                String orderId = parts[3];
                
                String bodyStr = readRequestBody(exchange);

                String newStatus = "PENDING";
                String statusMessage = "";
                if (bodyStr.contains("PREPARING")) {
                    newStatus = "PREPARING";
                    statusMessage = "Great news! Your order (" + orderId + ") is now being PREPARING 🍳";
                } else if (bodyStr.contains("COMPLETED")) {
                    newStatus = "COMPLETED";
                    statusMessage = "Your order (" + orderId + ") is ready and completed! Thank you for choosing Kasi Bites 🎉";
                }

                String customerPhone = "";
                for (Map<String, Object> order : orders) {
                    if (order.get("id").equals(orderId)) {
                        order.put("status", newStatus);
                        customerPhone = (String) order.get("customerPhone");
                        break;
                    }
                }

                if (!customerPhone.isEmpty() && !statusMessage.isEmpty()) {
                    System.out.println("📲 [SANDBOX NOTIFICATION to " + customerPhone + "]: " + statusMessage);
                }

                String resp = "{\"status\":\"success\"}";
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, resp.getBytes(StandardCharsets.UTF_8).length);
                OutputStream os = exchange.getResponseBody();
                os.write(resp.getBytes(StandardCharsets.UTF_8));
                os.close();
                
                System.out.println("🔄 Order " + orderId + " status updated to: " + newStatus);
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

            String rawBody = readRequestBody(exchange);
            
            String rawFrom = java.net.URLDecoder.decode(extractFormParam(rawBody, "From"), StandardCharsets.UTF_8);
            String customerPhone = rawFrom.replace("whatsapp:", "");
            String messageBody = java.net.URLDecoder.decode(extractFormParam(rawBody, "Body"), StandardCharsets.UTF_8);

            String orderId = "ORD-" + (new Random().nextInt(900) + 100);
            Map<String, Object> newOrder = new HashMap<>();
            newOrder.put("id", orderId);
            newOrder.put("customerName", "WhatsApp User");
            newOrder.put("customerPhone", customerPhone.isEmpty() ? "+27820000000" : customerPhone);
            newOrder.put("status", "PENDING");
            newOrder.put("timestamp", Instant.now().toString());

            List> items = new ArrayList<>();
            Map<String, Object> item = new HashMap<>();
            item.put("name", messageBody.isEmpty() ? "Standard Kota" : messageBody);
            item.put("quantity", 1);
            items.add(item);
            newOrder.put("items", items);

            orders.add(0, newOrder);

            String twiml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
               "<Response>" +
               "<Message>Your order (" + orderId + ") has been received by Kasi Bites! 🍳 We are getting it ready.</Message>" +
               "</Response>";
            exchange.getResponseHeaders().set("Content-Type", "text/xml");
            exchange.sendResponseHeaders(200, twiml.getBytes(StandardCharsets.UTF_8).length);
            OutputStream os = exchange.getResponseBody();
            os.write(twiml.getBytes(StandardCharsets.UTF_8));
            os.close();
            
            System.out.println("📲 New WhatsApp Order parsed and added: " + orderId + " -> " + messageBody);
        }
    }

    private static String extractJsonField(String json, String fieldName) {
        String searchKey = "\"" + fieldName + "\":";
        int idx = json.indexOf(searchKey);
        if (idx == -1) return "";
        int start = json.indexOf("\"", idx + searchKey.length());
        if (start == -1) return "";
        int end = json.indexOf("\"", start + 1);
        if (end == -1) return "";
        return json.substring(start + 1, end);
    }

    private static String toJsonArray(List> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            sb.append(mapToJson(list.get(i)));
            if (i < list.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    @SuppressWarnings("unchecked")
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