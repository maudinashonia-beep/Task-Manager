<!-- Reusable Futuristic Glassmorphic & 3D Tech Elements Component -->
<style>
    /* Technical Abstract Animations */
    .tech-element-container {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
        overflow: hidden;
        z-index: 2;
    }

    /* Floating Drifting Spheres */
    .glass-sphere {
        position: absolute;
        border-radius: 50%;
        animation: sphereDrift 20s infinite alternate ease-in-out;
        opacity: 0.25;
        mix-blend-mode: plus-lighter;
    }
    
    .sphere-1 {
        top: 15%;
        right: 12%;
        width: 160px;
        height: 160px;
        animation-duration: 22s;
    }

    .sphere-2 {
        bottom: 15%;
        left: 10%;
        width: 200px;
        height: 200px;
        animation-duration: 28s;
        animation-delay: -5s;
    }

    @keyframes sphereDrift {
        0% { transform: translate(0, 0) scale(1) rotate(0deg); }
        50% { transform: translate(25px, -30px) scale(1.08) rotate(180deg); }
        100% { transform: translate(-15px, 20px) scale(0.95) rotate(360deg); }
    }

    /* Tech Rings Spinning in 3D */
    .tech-ring-container {
        position: absolute;
        width: 300px;
        height: 300px;
        opacity: 0.15;
        mix-blend-mode: screen;
        perspective: 1000px;
    }

    .ring-left {
        bottom: 8%;
        left: 5%;
        animation: driftSlow 35s infinite alternate ease-in-out;
    }

    .ring-right {
        top: 8%;
        right: 5%;
        animation: driftSlow 30s infinite alternate ease-in-out -10s;
    }

    @keyframes driftSlow {
        0% { transform: translate(0,0) rotate(0deg); }
        100% { transform: translate(30px, 40px) rotate(15deg); }
    }

    .spinning-ring {
        width: 100%;
        height: 100%;
        transform-style: preserve-3d;
        animation: spinRing 25s infinite linear;
    }

    .spinning-ring-reverse {
        width: 100%;
        height: 100%;
        transform-style: preserve-3d;
        animation: spinRingRev 18s infinite linear;
    }

    @keyframes spinRing {
        from { transform: rotateX(65deg) rotateY(20deg) rotateZ(0deg); }
        to { transform: rotateX(65deg) rotateY(20deg) rotateZ(360deg); }
    }

    @keyframes spinRingRev {
        from { transform: rotateX(55deg) rotateY(-25deg) rotateZ(360deg); }
        to { transform: rotateX(55deg) rotateY(-25deg) rotateZ(0deg); }
    }

    /* Ambient cyber particles */
    .ambient-particle {
        position: absolute;
        background: #a78bfa;
        border-radius: 50%;
        opacity: 0;
        animation: twinkleParticle 4s infinite ease-in-out;
    }
    
    .particle-1 { top: 30%; left: 25%; width: 3px; height: 3px; animation-delay: 0.2s; }
    .particle-2 { top: 75%; left: 45%; width: 4px; height: 4px; animation-delay: 1.5s; background: #3b82f6; }
    .particle-3 { top: 20%; right: 30%; width: 3px; height: 3px; animation-delay: 2.8s; background: #ec4899; }
    .particle-4 { bottom: 30%; right: 20%; width: 4px; height: 4px; animation-delay: 0.9s; }

    @keyframes twinkleParticle {
        0%, 100% { opacity: 0; transform: translateY(0) scale(0.8); }
        50% { opacity: 0.8; transform: translateY(-15px) scale(1.2); filter: drop-shadow(0 0 4px currentColor); }
    }
</style>

<div class="tech-element-container">
    <!-- Specular radial gradients inside SVGs for realistic 3D look -->
    <svg style="position: absolute; width: 0; height: 0;">
        <defs>
            <radialGradient id="3dGlassGrad" cx="35%" cy="35%" r="65%">
                <stop offset="0%" stop-color="#c084fc" stop-opacity="0.6"/>
                <stop offset="35%" stop-color="#8b5cf6" stop-opacity="0.3"/>
                <stop offset="70%" stop-color="#3b82f6" stop-opacity="0.1"/>
                <stop offset="95%" stop-color="#080614" stop-opacity="0.4"/>
                <stop offset="100%" stop-color="#8b5cf6" stop-opacity="0.7"/>
            </radialGradient>
            <linearGradient id="ringNeonGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#a78bfa"/>
                <stop offset="50%" stop-color="#6366f1"/>
                <stop offset="100%" stop-color="#22d3ee"/>
            </linearGradient>
        </defs>
    </svg>

    <!-- 1. Floating Abstract Glass Spheres -->
    <!-- Sphere 1 (Top-Right) -->
    <div class="glass-sphere sphere-1">
        <svg viewBox="0 0 100 100" width="100%" height="100%">
            <circle cx="50" cy="50" r="48" fill="url(#3dGlassGrad)" stroke="rgba(255,255,255,0.15)" stroke-width="0.5"/>
            <!--Specularity -->
            <ellipse cx="38" cy="38" rx="12" ry="6" transform="rotate(-30 38 38)" fill="white" opacity="0.12"/>
        </svg>
    </div>
    
    <!-- Sphere 2 (Bottom-Left) -->
    <div class="glass-sphere sphere-2">
        <svg viewBox="0 0 100 100" width="100%" height="100%">
            <circle cx="50" cy="50" r="48" fill="url(#3dGlassGrad)" stroke="rgba(255,255,255,0.15)" stroke-width="0.5"/>
            <ellipse cx="38" cy="38" rx="12" ry="6" transform="rotate(-30 38 38)" fill="white" opacity="0.12"/>
        </svg>
    </div>

    <!-- 2. Cybernetic Neon Tech Rings (Perspectival spinning) -->
    <!-- Ring Left -->
    <div class="tech-ring-container ring-left">
        <div class="spinning-ring">
            <svg viewBox="0 0 200 200" width="100%" height="100%">
                <circle cx="100" cy="100" r="90" fill="none" stroke="url(#ringNeonGrad)" stroke-width="1.5" stroke-dasharray="8 6"/>
                <circle cx="100" cy="100" r="76" fill="none" stroke="#22d3ee" stroke-width="0.8" stroke-opacity="0.3" stroke-dasharray="40 10 5 10"/>
                <circle cx="100" cy="100" r="96" fill="none" stroke="#a78bfa" stroke-width="0.5" stroke-opacity="0.2"/>
            </svg>
        </div>
    </div>

    <!-- Ring Right -->
    <div class="tech-ring-container ring-right">
        <div class="spinning-ring-reverse">
            <svg viewBox="0 0 200 200" width="100%" height="100%">
                <circle cx="100" cy="100" r="90" fill="none" stroke="url(#ringNeonGrad)" stroke-width="1.5" stroke-dasharray="12 8"/>
                <circle cx="100" cy="100" r="76" fill="none" stroke="#e879f9" stroke-width="0.8" stroke-opacity="0.3" stroke-dasharray="25 15"/>
                <circle cx="100" cy="100" r="96" fill="none" stroke="#3b82f6" stroke-width="0.5" stroke-opacity="0.2"/>
            </svg>
        </div>
    </div>

    <!-- 3. Twinkling Ambient Cyber Particles -->
    <div class="ambient-particle particle-1"></div>
    <div class="ambient-particle particle-2"></div>
    <div class="ambient-particle particle-3"></div>
    <div class="ambient-particle particle-4"></div>
</div>
