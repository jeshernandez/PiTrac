// Dashboard-specific functionality (theme and dropdown handled by common.js)
let ws = null;

const normalizeText = (value) => (value || '').toLowerCase();

const BALL_STATUS_RULES = [
    {
        className: 'initializing',
        title: 'System Initializing',
        defaultMessage: 'Starting up PiTrac system...',
        match: ({ type }) => type.includes('initializing'),
    },
    {
        className: 'waiting',
        title: 'Waiting for Ball',
        defaultMessage: 'Please place ball on tee',
        match: ({ type }) => type.includes('waiting for ball'),
    },
    {
        className: 'waiting',
        title: 'Waiting for Simulator',
        defaultMessage: 'Waiting for simulator to be ready',
        match: ({ type }) => type.includes('waiting for simulator'),
    },
    {
        className: 'stabilizing',
        title: 'Ball Detected',
        defaultMessage: 'Waiting for ball to stabilize...',
        match: ({ type }) => type.includes('pausing') || type.includes('stabilization'),
    },
    {
        className: 'ready',
        title: 'Ready to Hit!',
        defaultMessage: 'Ball is ready - take your shot!',
        match: ({ type, message }) =>
            type.includes('ball ready') ||
            type.includes('ready') ||
            type.includes('ball placed') ||
            message.includes("let's golf"),
    },
    {
        className: 'hit',
        title: 'Ball Hit!',
        defaultMessage: 'Processing shot data...',
        match: ({ type }) => type.includes('hit'),
    },
    {
        className: 'error',
        title: 'Error',
        defaultMessage: 'An error occurred',
        match: ({ type }) => type.includes('error'),
    },
    {
        className: 'error',
        title: 'Multiple Balls Detected',
        defaultMessage: 'Please remove extra balls',
        match: ({ type }) => type.includes('multiple balls'),
    },
];

const HIT_IMAGE_NAME = 'ball_exposure_candidates.png';
const HIT_IMAGE_URL = `/images/${HIT_IMAGE_NAME}`;
let hitImageTimer = null;

const setBallReadyImageVisible = (isVisible) => {
    const container = document.getElementById('ball-ready-image');
    if (!container) {
        return;
    }
    if (isVisible) {
        container.classList.add('visible');
    } else {
        container.classList.remove('visible');
    }
};

const clearShotImages = () => {
    const imageGrid = document.getElementById('image-grid');
    if (imageGrid) {
        imageGrid.innerHTML = '';
    }
};

const hideBallHitImage = () => {
    if (hitImageTimer) {
        clearTimeout(hitImageTimer);
        hitImageTimer = null;
    }

    const container = document.getElementById('ball-hit-image');
    if (!container) {
        return;
    }
    container.classList.remove('visible');
    const img = container.querySelector('img');
    if (img) {
        const baseSrc = img.dataset.baseSrc || HIT_IMAGE_URL;
        img.src = baseSrc;
        img.onload = null;
        img.onerror = null;
    }
};

const resolveImagePath = (path) => {
    if (!path) {
        return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
        return path;
    }
    if (path.startsWith('/')) {
        return path;
    }
    return `/images/${path.replace(/^\/+/, '')}`;
};

const showBallHitImage = (overridePath = null) => {
    const container = document.getElementById('ball-hit-image');
    const img = container ? container.querySelector('img') : null;

    if (!container || !img) {
        return;
    }

    const cleanup = () => {
        img.onload = null;
        img.onerror = null;
        hitImageTimer = null;
    };

    img.onload = () => {
        cleanup();
        container.classList.add('visible');
    };

    img.onerror = () => {
        cleanup();
        hideBallHitImage();
        clearShotImages();
    };

    const baseSrc = resolveImagePath(overridePath) || img.dataset.baseSrc || HIT_IMAGE_URL;
    img.src = `${baseSrc}?t=${Date.now()}`;
};

function connectWebSocket() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    ws = new WebSocket(`${protocol}//${window.location.host}/ws`);

    ws.onopen = () => {
        // WebSocket connected
        document.getElementById('ws-status-dot').classList.remove('disconnected');
    };

    ws.onmessage = (event) => {
        const data = JSON.parse(event.data);
        updateDisplay(data);
    };

    ws.onclose = () => {
        // WebSocket disconnected
        document.getElementById('ws-status-dot').classList.add('disconnected');
        setTimeout(connectWebSocket, 3000);
    };

    ws.onerror = (error) => {
        console.error('WebSocket error:', error);
    };
}

function updateDisplay(data) {
    const updateMetric = (id, value) => {
        const element = document.getElementById(id);
        const oldValue = element.textContent;
        if (oldValue !== value.toString()) {
            element.textContent = value;
            element.parentElement.classList.add('updated');
            setTimeout(() => {
                element.parentElement.classList.remove('updated');
            }, 500);
        }
    };

    updateMetric('speed', data.speed || '0.0');
    updateMetric('carry', data.carry || '0.0');
    updateMetric('launch_angle', data.launch_angle || '0.0');
    updateMetric('side_angle', data.side_angle || '0.0');
    updateMetric('back_spin', data.back_spin || '0');
    updateMetric('side_spin', data.side_spin || '0');

    // Update ball ready status indicator
    updateBallStatus(data.result_type, data.message, data.pitrac_running);

    if (data.timestamp) {
        const date = new Date(data.timestamp);
        document.getElementById('timestamp').textContent = date.toLocaleTimeString();
    }

    // Update images - only show images for actual hits, clear for status messages
    const imageGrid = document.getElementById('image-grid');
    const resultType = normalizeText(data.result_type);

    if (resultType.includes('hit')) {
        imageGrid.innerHTML = '';
    } else if (resultType.includes('ready')) {
        imageGrid.innerHTML = '';
        hideBallHitImage();
    } else {
        imageGrid.innerHTML = '';
    }
}

function updateBallStatus(resultType, message, isPiTracRunning) {
    const indicator = document.getElementById('ball-ready-indicator');
    const statusTitle = document.getElementById('ball-status-title');
    const statusMessage = document.getElementById('ball-status-message');

    indicator.classList.remove('initializing', 'waiting', 'stabilizing', 'ready', 'hit', 'error');
    setBallReadyImageVisible(false);

    if (isPiTracRunning === false) {
        indicator.classList.add('error');
        statusTitle.textContent = 'System Stopped';
        statusMessage.textContent = 'Start PiTrac...';
        hideBallHitImage();
        clearShotImages();
        return;
    }

    if (resultType) {
        const normalizedType = normalizeText(resultType);
        const normalizedMessage = normalizeText(message);
        const statusContext = { type: normalizedType, message: normalizedMessage };
        const rule = BALL_STATUS_RULES.find((r) => r.match(statusContext));

        if (rule) {
            indicator.classList.add(rule.className);
            statusTitle.textContent = rule.title;
            statusMessage.textContent = message || rule.defaultMessage;
            setBallReadyImageVisible(rule.className === 'ready');

            if (rule.className === 'ready') {
                hideBallHitImage();
            } else if (rule.className === 'hit') {
                if (hitImageTimer) {
                    clearTimeout(hitImageTimer);
                }
                hitImageTimer = setTimeout(() => showBallHitImage(), 2000);
            }
        } else {
            statusTitle.textContent = 'System Status';
            statusMessage.textContent = message || resultType;
        }
    } else {
        setBallReadyImageVisible(false);
    }
}

function openImage(imgPath) {
    window.open(`/images/${imgPath}`, '_blank');
}

async function resetShot() {
    try {
        const response = await fetch('/api/reset', { method: 'POST' });
        if (response.ok) {
        }
    } catch (error) {
        console.error('Error resetting shot:', error);
    }
}


let originalCheckPiTracStatus;
const dashboardCheckPiTracStatus = async function() {
    if (!originalCheckPiTracStatus) {
        originalCheckPiTracStatus = window.checkPiTracStatus;
    }
    const isRunning = await originalCheckPiTracStatus();
    
    if (!isRunning) {
        updateBallStatus(null, null, false);
    }
    
    return isRunning;
}

function showStatusMessage(message, type = 'info') {
    const statusMessage = document.getElementById('ball-status-message');
    if (statusMessage) {
        const originalMessage = statusMessage.textContent;
        statusMessage.textContent = message;
        statusMessage.className = `ball-status-message ${type}`;

        setTimeout(() => {
            statusMessage.textContent = originalMessage;
            statusMessage.className = 'ball-status-message';
        }, 3000);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    connectWebSocket();
    
    updateBallStatus('Initializing', 'System starting up...');
    
    if (window.checkPiTracStatus) {
        originalCheckPiTracStatus = window.checkPiTracStatus;
        window.checkPiTracStatus = dashboardCheckPiTracStatus;
    }
    
    document.addEventListener('visibilitychange', () => {
        if (!document.hidden && (!ws || ws.readyState !== WebSocket.OPEN)) {
            connectWebSocket();
        }
    });
});
