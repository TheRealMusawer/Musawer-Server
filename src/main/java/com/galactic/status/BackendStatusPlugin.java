package com.galactic.status;

import com.google.inject.Inject;
import com.velocitypowered.api.event.Subscribe;
import com.velocitypowered.api.event.player.PlayerChooseInitialServerEvent;
import com.velocitypowered.api.event.player.ServerConnectedEvent;
import com.velocitypowered.api.event.player.DisconnectEvent;
import com.velocitypowered.api.plugin.Plugin;
import com.velocitypowered.api.proxy.ProxyServer;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;

@Plugin(
        id = "backendstatus",
        name = "BackendStatus",
        version = "1.0",
        authors = {"Galactic"}
)
public class BackendStatusPlugin {

    private final ProxyServer server;
    private final Path dataDirectory;

    @Inject
    public BackendStatusPlugin(ProxyServer server, Path dataDirectory) {
        this.server = server;
        this.dataDirectory = dataDirectory;
    }

    @Subscribe
    public void onJoin(ServerConnectedEvent e) {
        updateStatus();
    }

    @Subscribe
    public void onLeave(DisconnectEvent e) {
        updateStatus();
    }

    @Subscribe
    public void onInitial(PlayerChooseInitialServerEvent e) {
        updateStatus();
    }

    private void updateStatus() {
        int players = server.getPlayerCount();
        File file = dataDirectory.resolve("status.txt").toFile();

        try (FileWriter writer = new FileWriter(file, false)) {
            writer.write("players=" + players);
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
}
