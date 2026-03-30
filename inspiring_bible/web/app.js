const app = document.getElementById('app');
const verseFrame = document.getElementById('verse-frame');
const uiTitle = document.getElementById('ui-title');
const uiSubtitle = document.getElementById('ui-subtitle');
const uiFooter = document.getElementById('ui-footer');
const themeName = document.getElementById('theme-name');
const translationName = document.getElementById('translation-name');
const verseCounter = document.getElementById('verse-counter');
const verseTitle = document.getElementById('verse-title');
const verseReference = document.getElementById('verse-reference');
const verseText = document.getElementById('verse-text');

const prevButton = document.getElementById('prev-btn');
const nextButton = document.getElementById('next-btn');
const shuffleButton = document.getElementById('shuffle-btn');
const closeButton = document.getElementById('close-btn');

let verses = [];
let currentIndex = 0;
let visible = false;
let lastActionAt = 0;
let transitionFrame = 0;

const ACTION_COOLDOWN_MS = 140;

const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'inspiring_bible';

function post(eventName, data = {}) {
    fetch(`https://${resourceName}/${eventName}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
    }).catch(() => {});
}

function clampIndex(index) {
    if (verses.length === 0) {
        return 0;
    }

    if (index < 0) {
        return verses.length - 1;
    }

    if (index >= verses.length) {
        return 0;
    }

    return index;
}

function animateVerseSwap(callback) {
    callback();

    verseFrame.classList.remove('is-transitioning');

    if (transitionFrame) {
        cancelAnimationFrame(transitionFrame);
    }

    transitionFrame = requestAnimationFrame(() => {
        verseFrame.classList.add('is-transitioning');
        transitionFrame = 0;
    });
}

function canRunAction() {
    if (!visible || verses.length === 0) {
        return false;
    }

    const now = performance.now();

    if ((now - lastActionAt) < ACTION_COOLDOWN_MS) {
        return false;
    }

    lastActionAt = now;
    return true;
}

function renderVerse() {
    const verse = verses[currentIndex];

    if (!verse) {
        return;
    }

    themeName.textContent = verse.theme || 'Hope';
    verseCounter.textContent = `${currentIndex + 1} / ${verses.length}`;
    verseTitle.textContent = verse.title || 'Reading Focus';
    verseReference.textContent = verse.reference || '';
    verseText.textContent = verse.text || '';
}

function showVerse(index) {
    currentIndex = clampIndex(index);
    animateVerseSwap(renderVerse);
}

function showPrevious() {
    if (!canRunAction()) {
        return;
    }

    showVerse(currentIndex - 1);
}

function showNext() {
    if (!canRunAction()) {
        return;
    }

    showVerse(currentIndex + 1);
}

function shuffleVerse() {
    if (!canRunAction()) {
        return;
    }

    if (verses.length < 2) {
        showVerse(0);
        return;
    }

    let nextIndex = currentIndex;

    while (nextIndex === currentIndex) {
        nextIndex = Math.floor(Math.random() * verses.length);
    }

    showVerse(nextIndex);
}

function openUi(payload) {
    verses = Array.isArray(payload.verses) ? payload.verses : [];
    currentIndex = clampIndex((payload.currentIndex || 1) - 1);
    lastActionAt = 0;

    uiTitle.textContent = payload.ui?.title || 'Holy Bible';
    uiSubtitle.textContent = payload.ui?.subtitle || 'Thirty verses for peace, courage, rest, and hope.';
    uiFooter.textContent = payload.ui?.footer || 'Be still, and know that I am God.';
    translationName.textContent = payload.ui?.translation || 'KJV';

    visible = true;
    document.body.classList.add('body--visible');
    app.classList.add('app--visible');
    app.setAttribute('aria-hidden', 'false');
    renderVerse();
}

function closeUi(notifyGame = true) {
    visible = false;
    app.classList.remove('app--visible');
    document.body.classList.remove('body--visible');
    app.setAttribute('aria-hidden', 'true');

    if (transitionFrame) {
        cancelAnimationFrame(transitionFrame);
        transitionFrame = 0;
    }

    if (notifyGame) {
        post('close');
    }
}

window.addEventListener('message', (event) => {
    const payload = event.data;

    if (!payload || !payload.action) {
        return;
    }

    if (payload.action === 'open') {
        openUi(payload);
        return;
    }

    if (payload.action === 'close') {
        closeUi(false);
    }
});

window.addEventListener('keydown', (event) => {
    if (!visible || event.repeat) {
        return;
    }

    if (event.key === 'Escape') {
        post('escapePressed');
        closeUi(false);
        return;
    }

    if (event.key === 'ArrowLeft') {
        event.preventDefault();
        showPrevious();
        return;
    }

    if (event.key === 'ArrowRight') {
        event.preventDefault();
        showNext();
        return;
    }

    if (event.key === ' ' || event.key === 'Spacebar') {
        event.preventDefault();
        shuffleVerse();
    }
});

function bindButton(button, handler) {
    button.onclick = (event) => {
        event.preventDefault();
        event.stopPropagation();
        button.blur();
        handler();
    };
}

bindButton(prevButton, showPrevious);
bindButton(nextButton, showNext);
bindButton(shuffleButton, shuffleVerse);
bindButton(closeButton, () => closeUi(true));

closeUi(false);
