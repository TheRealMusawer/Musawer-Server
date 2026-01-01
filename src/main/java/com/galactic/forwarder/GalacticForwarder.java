package com.galactic.forwarder;

import com.velocitypowered.api.event.Subscribe;
import com.velocitypowered.api.event.connection.PostLoginEvent;
import com.velocitypowered.api.plugin.Plugin;
import com.velocitypowered.api.proxy.Player;
import com.velocitypowered.api.proxy.ProxyServer;
import com.velocitypowered.api.proxy.server.RegisteredServer;

import javax.inject.Inject;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.Scanner;

@Plugin(
        id = "galacticforwarder",
        name = "GalacticForwarder",
        version = "1.1.0",
        authors = {"Mohammad"}
)
public class GalacticForwarder {

    private final ProxyServer server;

    @Inject
    public GalacticForwarder(ProxyServer server) {
        this.server = server;
    }

    // Fetch players with timeout + offline detection
    private int fetchPlayers(String host) {
        try {
            URL url = new URL("https://" + host + "/status.txt");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(1500);
            conn.setReadTimeout(1500);

            Scanner sc = new Scanner(conn.getInputStream());
            while (sc.hasNextLine()) {
                String line = sc.nextLine();
                if (line.startsWith("players=")) {
                    return Integer.parseInt(line.replace("players=", "").trim());
                }
            }
        } catch (Exception ignored) {}

        return -1; // offline
    }

    @Subscribe
    public void onJoin(PostLoginEvent event) {
        Player player = event.getPlayer();

        Map<String, String> backends = Map.of(
                "p1", "bachi-eagler.onrender.com",
                "p2", "abdullo-eagler.onrender.com",
                "p3", "leon-eagler.onrender.com",
                "p4", "oneil-eagler.onrender.com",
                "p5", "ahmad-eagler.onrender.com",
                "p6", "fahad-eagler.onrender.com",
                "p7", "azan-eagler.onrender.com"
        );

        CompletableFuture.runAsync(() -> {

            Map<String, Integer> online = new HashMap<>();

            // Fetch loads
            for (var entry : backends.entrySet()) {
                int count = fetchPlayers(entry.getValue());
                if (count >= 0) {
                    online.put(entry.getKey(), count);
                }
            }

            if (online.isEmpty()) {
                System.out.println("[Forwarder] No backend servers online.");
                return;
            }

            // STEP 1: Prefer servers with < 3 players
            Optional<Map.Entry<String, Integer>> under3 = online.entrySet()
                    .stream()
                    .filter(e -> e.getValue() < 3)
                    .sorted(Map.Entry.comparingByValue())
                    .findFirst();

            String targetName;

            if (under3.isPresent()) {
                targetName = under3.get().getKey();
                System.out.println("[Forwarder] Sending " + player.getUsername() +
                        " to <3 server: " + targetName);
            } else {
                // STEP 2: Fallback to lowest player count
                targetName = online.entrySet()
                        .stream()
                        .sorted(Map.Entry.comparingByValue())
                        .findFirst()
                        .get()
                        .getKey();

                System.out.println("[Forwarder] Sending " + player.getUsername() +
                        " to lowest-load server: " + targetName);
            }

            RegisteredServer target = server.getServer(targetName).orElse(null);
            if (target != null) {
                player.createConnectionRequest(target).connect();
            } else {
                System.out.println("[Forwarder] ERROR: Server " + targetName + " not registered in velocity.toml");
            }
        });
    }
}
