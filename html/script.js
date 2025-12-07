let root;
let timerEl;
let timerWrapperEl;
let bgVideo;

let timerInterval = null;
let remainingSeconds = 0;

function formatTime(sec) {
    const m = Math.floor(sec / 60);
    const s = Math.floor(sec % 60);
    const mm = m.toString().padStart(2, "0");
    const ss = s.toString().padStart(2, "0");
    return `${mm}:${ss}`;
}

function updateTimerDisplay() {
    if (!timerEl) return;
    timerEl.textContent = formatTime(remainingSeconds);
}

function startTimer() {
    clearInterval(timerInterval);
    updateTimerDisplay();

    timerInterval = setInterval(() => {
        if (remainingSeconds <= 0) {
            remainingSeconds = 0;
            updateTimerDisplay();
            clearInterval(timerInterval);
            return;
        }
        remainingSeconds--;
        updateTimerDisplay();
    }, 1000);
}

function openMortuaryUi(data) {
    if (!root) return;

    root.classList.add("visible");

    if (timerWrapperEl) {
        timerWrapperEl.style.display = data.showTimer ? "inline-flex" : "none";
    }

    if (data.showTimer) {
        remainingSeconds = data.remainingSeconds || 0;
        startTimer();
    } else {
        clearInterval(timerInterval);
    }

    if (bgVideo) {
        if (data.videoEnabled) {
            bgVideo.src = "video.mp4";
            bgVideo.style.display = "block";
            bgVideo.currentTime = 0;
            bgVideo.play().catch(() => {});
        } else {
            bgVideo.pause();
            bgVideo.removeAttribute("src");
            bgVideo.load();
            bgVideo.style.display = "none";
        }
    }
}

function closeMortuaryUi() {
    if (!root) return;

    root.classList.remove("visible");
    clearInterval(timerInterval);

    if (bgVideo) {
        bgVideo.pause();
        bgVideo.removeAttribute("src");
        bgVideo.load();
        bgVideo.style.display = "none";
    }
}

window.addEventListener("DOMContentLoaded", () => {
    root = document.getElementById("mortuary-root");
    timerEl = document.getElementById("timer");
    timerWrapperEl = document.getElementById("timer-wrapper");
    bgVideo = document.getElementById("bg-video");

    if (root) {
        root.classList.remove("visible");
    }
});

window.addEventListener("message", (event) => {
    const data = event.data || {};

    if (data.action === "openMortuaryUi") {
        openMortuaryUi(data);
    }

    if (data.action === "closeMortuaryUi") {
        closeMortuaryUi();
    }
});
