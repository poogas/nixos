{ config, pkgs, ... }:
{
  networking.hosts = {
    "127.0.0.1" = [
      "localhost"
      "only-fans.uk"
      "only-fans.me"
      "onlyfans.wtf"
      "iplogger.org"
      "wl.gl"
      "ed.tc"
      "bc.ax"
      "maper.info"
      "2no.co"
      "yip.su"
      "iplis.ru"
      "ezstat.ru"
      "iplog.co"
      "grabify.org"
    ];

    "::1" = [ "ip6-localhost" ];

    "157.240.245.174" = [
      "instagram.com"
      "www.instagram.com"
      "b.i.instagram.com"
      "z-p42-chat-e2ee-ig.facebook.com"
    ];

    "3.66.189.153" = [
      "protonmail.com"
      "mail.proton.me"
    ];

    "64.233.164.198" = [
      "yt3.ggpht.com"
    ];

    "204.12.192.222" = [
      "chatgpt.com"
      "ab.chatgpt.com"
      "auth.openai.com"
      "auth0.openai.com"
      "platform.openai.com"
      "cdn.oaistatic.com"
      "files.oaiusercontent.com"
      "cdn.auth0.com"
      "tcr9i.chat.openai.com"
      "webrtc.chatgpt.com"
      "gemini.google.com"
      "aistudio.google.com"
      "generativelanguage.googleapis.com"
      "aitsandbox-pa.googleapis.com"
      "proactivebackend-pa.googleapis.com"
      "o.pki.goog"
      "labs.google"
      "notebooklm.google"
      "notebooklm.google.com"
      "copilot.microsoft.com"
      "sydney.bing.com"
      "edgeservices.bing.com"
      "api.spotify.com"
      "xpui.app.spotify.com"
      "appresolve.spotify.com"
      "login5.spotify.com"
      "login.app.spotify.com"
      "encore.scdn.co"
      "ap-gew1.spotify.com"
      "gew1-spclient.spotify.com"
      "spclient.wg.spotify.com"
      "api-partner.spotify.com"
      "aet.spotify.com"
      "www.spotify.com"
      "accounts.spotify.com"
      "open.spotify.com"
      "claude.ai"
      "www.notion.so"
      "www.canva.com"
      "www.intel.com"
      "developer.nvidia.com"
      "builds.parsec.app"
      "download.jetbrains.com"
    ];

    "204.12.192.221" = [
      "rewards.bing.com"
      "alkalimakersuite-pa.clients6.google.com"
      "assistant-s3-pa.googleapis.com"
      "www.dell.com"
      "truthsocial.com"
      "static-assets-1.truthsocial.com"
      "images.tidal.com"
      "fsu.fa.tidal.com"
    ];

    "78.40.217.193" = [
      "xsts.auth.xboxlive.com"
    ];

    "50.7.87.86" = [
      "xgpuwebf2p.gssv-play-prod.xboxlive.com"
    ];

    "50.7.87.85" = [
      "codeium.com"
    ];

    "50.7.85.221" = [
      "datalore.jetbrains.com"
    ];

    "50.7.87.83" = [
      "proxy.individual.githubcopilot.com"
    ];

    "107.150.34.100" = [
      "plugins.jetbrains.com"
    ];

    "3.160.212.81" = [
      "cdn.id.supercell.com"
    ];

    "18.172.112.81" = [
      "security.id.supercell.com"
    ];

    "3.165.113.14" = [
      "accounts.supercell.com"
    ];

    "18.66.195.96" = [
      "game-assets.clashroyaleapp.com"
    ];

    "51.158.190.98" = [
      "game.clashroyaleapp.com"
    ];

    "3.162.38.39" = [
      "game-assets.clashofclans.com"
    ];

    "70.34.251.56" = [
      "gamea.clashofclans.com"
    ];

    "108.157.194.81" = [
      "clashofclans.inbox.supercell.com"
    ];

    "179.43.168.109" = [
      "game.brawlstarsgame.com"
    ];

    "18.239.69.129" = [
      "game-assets.brawlstarsgame.com"
    ];

    "50.7.85.219" = [
      "inference.codeium.com"
      "datalore.jetbrains.com"
      "www.tiktok.com"
    ];

    "142.54.189.106" = [
      "web.archive.org"
    ];
  };
}
