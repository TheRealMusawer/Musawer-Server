package com.galactic.forwarder;

import com.velocitypowered.api.event.Subscribe;
import com.velocitypowered.api.event.connection.PostLoginEvent;
import com.velocitypowered.api.plugin.Plugin;
import com.velocitypowered.api.proxy.Player;
import com.velocitypowered.api.proxy.ProxyServer;
import com.velocitypowered.api.proxy.server.RegisteredServer;

import javax.inject.Inject;
import java.net.URL;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.Scanner;

@Plugin(
        id = "galacticforwarder",
        name = "GalacticForwarder",
        version = "1.0.0",
        authors = {"Mohammad"}
)
public class GalacticForwarder {

    private final ProxyServer server;

    @Inject
    public GalacticForwarder(ProxyServer server) {
        this.server = server;
    }

    private int fetchPlayers(String host) {
        try {
            URL url = new URL("https://" + host + "/status.txt");
            Scanner sc = new Scanner(url.openStream());
            while (sc.hasNextLine()) {
                String line = sc.nextLine();
                if (line.startsWith("players=")) {
                    return Integer.parseInt(line.replace("players=", "").trim());
                }
            }
        } catch (Exception ignored) {}
        return 999;
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
            Map<String, Integer> loads = new HashMap<>();

            for (var entry : backends.entrySet()) {
                loads.put(entry.getKey(), fetchPlayers(entry.getValue()));
            }

            Optional<Map.Entry<String, Integer>> best = loads.entrySet()
                    .stream()
                    .sorted(Map.Entry.comparingByValue())
                    .findFirst();

            if (best.isEmpty()) return;

            String targetName = best.get().getKey();
            RegisteredServer target = server.getServer(targetName).orElse(null);

            if (target != null) {
                player.createConnectionRequest(target).connect();
            }
        });
    }
}
