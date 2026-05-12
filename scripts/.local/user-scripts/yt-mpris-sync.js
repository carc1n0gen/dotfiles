// ==UserScript==
// @name        YouTube MPRIS Volume Sync
// @match       *://www.youtube.com/*
// @run-at      document-idle
// ==/UserScript==

(function () {
  const script = document.createElement("script");
  script.textContent = `(${function () {
    let syncing = false;

    function getPlayer() {
      const el = document.querySelector("#movie_player");
      return el && typeof el.setVolume === "function" ? el : null;
    }

    function sync(video) {
      if (syncing) return;
      const player = getPlayer();
      if (!player) return;

      const percent = Math.round(video.volume * 100);
      const ytVol = player.getVolume();

      if (Math.abs(ytVol - percent) < 2) return;

      syncing = true;
      player.setVolume(percent);
      syncing = false;
    }

    function attach(video) {
      if (video._mprisSyncAttached) return;
      video._mprisSyncAttached = true;
      video.addEventListener("volumechange", () => sync(video));
    }

    const observer = new MutationObserver(() => {
      const video = document.querySelector("video");
      if (video) attach(video);
    });
    observer.observe(document.body, { childList: true, subtree: true });

    const video = document.querySelector("video");
    if (video) attach(video);
  }})();`;

  document.documentElement.appendChild(script);
  script.remove();
})();
