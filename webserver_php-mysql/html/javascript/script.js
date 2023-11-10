// Particles Configuration
const particlesConfig = {
    fpsLimit: 60,
    particles: {
      number: { value: 50, density: { enable: true, area: 800 } },
      color: { value: "#ffffff" },
      shape: { type: "circle" },
      opacity: { value: 1, random: { enable: true, minimumValue: 0.1 } },
      size: { value: 1, random: { enable: true, minimumValue: 1 } },
      move: { enable: true, speed: 0.2, direction: "none", random: true, straight: false, outModes: { default: "out" } }
    },
    interactivity: { detectsOn: "canvas", events: { resize: true } },
    detectRetina: true
  };
  tsParticles.load("tsparticles", particlesConfig);
  
  // DOM Content Loaded Event Actions
  document.addEventListener('DOMContentLoaded', (event) => {
    setTimeout(() => {
      document.querySelector('.error-message').style.opacity = 1;
    }, 500);
  });
  
  // JQuery Ready Function
  $(document).ready(function() {
    // Cookie Banner Handling
    var cookieAccepted = document.cookie.split(';').some(item => item.trim().startsWith('cookieAccepted=true'));
    if (cookieAccepted) {
      $("#cookie-banner").fadeOut("slow");
    } else {
      $("#cookie-banner").show();
      $("#cookie-accept").click(function() {
        var expires = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toUTCString();
        document.cookie = "cookieAccepted=true; expires=" + expires + "; path=/";
        $("#cookie-banner").fadeOut("slow");
      });
    }
  
    $(document).ready(function() {
        $('#datenschutz-link').click(function(e) {
          e.preventDefault();
          $('#overlay').fadeIn('fast');
          $('#datenschutz-modal').fadeIn('slow');
        });
      
        // Klick-Event für das Schließen-Icon im Datenschutz-Div
        $('#datenschutz-close').click(function() {
          $('#datenschutz-modal').fadeOut('slow');
          $('#overlay').fadeOut('fast');
        });
      
        // Klick-Event für das Overlay, um das Datenschutz-Div zu schließen
        $('#overlay').click(function() {
          $('#datenschutz-modal').fadeOut('slow');
          $(this).fadeOut('fast');
        });
      });
      
  
    // Email Obfuscation
    var user = 'datenschutz';
    var domain = 'domain.de';
    var elem = document.querySelector('#datenschutz-content a');
    elem.href = 'mailto:' + user + '@' + domain;
    elem.textContent = user + '@' + domain;
  
    // Comet Animations
    function createComet() {
      const comet = document.createElement('div');
      comet.classList.add('comet');
      document.body.appendChild(comet);
      const maxRight = window.innerWidth;
      const maxTop = window.innerHeight / 2;
      const startX = window.innerWidth - (Math.random() * maxRight / 2);
      const startY = Math.random() * maxTop;
      const endX = -100;
      const endY = window.innerHeight;
      const duration = Math.random() * 3000 + 2000;
      comet.style.left = `${startX}px`;
      comet.style.top = `${startY}px`;
      comet.style.animation = `burning ${duration / 1000}s ease-in-out forwards`;
      comet.animate([
        { transform: `translate3d(0, 0, 0)`, opacity: 1 },
        { transform: `translate3d(${endX - startX}px, ${endY - startY}px, 0)`, opacity: 0 }
      ], {
        duration: duration,
        iterations: 1,
        fill: 'forwards'
      });
      setTimeout(() => { comet.remove(); }, duration);
    }
  
    function startCometAnimations() {
      const minDelay = 100;
      const maxDelay = 500;
      const numberOfComets = Math.floor(Math.random() * 5) + 1;
      for (let i = 0; i < numberOfComets; i++) {
        setTimeout(createComet, Math.random() * (maxDelay - minDelay) + minDelay);
      }
    }
  
    startCometAnimations();
    setInterval(startCometAnimations, 2000);
  });
  