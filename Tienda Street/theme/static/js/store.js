/**
 * Store JS
 * Main JavaScript file for theme functionality
 * Organized by: Utilities > Sections > Core > Category > PDP > Cart > Init
 */

(function() {
  'use strict';

  // Tracked early (before DOMContentLoaded) so deferOnMobile doesn't miss taps that happen before init runs.
  var mobileInteracted = false;
  document.addEventListener('pointerdown', function() { mobileInteracted = true; }, { once: true, passive: true });

  /* ========================================
   * UTILITIES
   * ========================================
   * General helpers and initialization
   * - Modal handler
   * - Fade transitions
   * - deferOnMobile
   */

  let modalHandler = null;
  let heroParallaxScrollHandler = null;

  function initModalHandler() {
    modalHandler = new ModalHandler();
  }

  // Fade helpers: replicate jQuery fadeOut/fadeIn using inline transitions
  function fadeOut(el) {
    if (!el) return;
    el.style.transition = 'opacity 0.3s';
    el.style.opacity = '0';
    setTimeout(function() { el.style.display = 'none'; }, 300);
  }
  function fadeIn(el) {
    if (!el) return;
    el.style.display = '';
    el.style.opacity = '0';
    el.style.transition = 'opacity 0.3s';
    requestAnimationFrame(function() { el.style.opacity = '1'; });
  }

  /**
   * Defers a callback until the first user interaction on mobile.
   * Runs immediately on desktop or in preview mode.
   */
  function deferOnMobile(callback) {
    if (window.innerWidth < 768 && document.body.dataset.preview !== 'true') {
      if (mobileInteracted) {
        callback();
      } else {
        document.addEventListener('pointerdown', callback, { once: true, passive: true });
      }
    } else {
      callback();
    }
  }

  /* ========================================
   * SECTIONS
   * ======================================== 
   * - Swipers (slideshow, featured products, testimonials, carousel, banners, icon text)
   * - Countdown
   * - Timer offers
   * - Video blocks
   * - Popup
   * - Announcement bar
   * - Newsletter
   */

  /**
   * Swipers
   * Initializes all Swiper carousels (slideshows, product sliders, featured products).
   */

  /**
 * Hides swiper pagination when there is only one bullet (all slides fit in view).
 */
  function hideSingleBulletPagination(swiperEl) {
    const paginationEl = swiperEl.querySelector('.swiper-pagination');
    if (paginationEl) {
      const bullets = paginationEl.querySelectorAll('.swiper-pagination-bullet');
      paginationEl.style.display = bullets.length <= 1 ? 'none' : '';
    }
  }
  
  function initSwipers() {

    // Slideshow sections
    document.querySelectorAll('.js-slideshow').forEach(function(swiperContainer) {
      if (swiperContainer.swiper) return;

      // Resolve navigation, pagination and fraction elements from data attributes

      const autoplay = swiperContainer.dataset.autoplay === 'true';
      const speed = parseInt(swiperContainer.dataset.speed, 10) || 5000;
      const deferInit = swiperContainer.dataset.priority !== 'true';
      const deferAutoplay = autoplay;
      const parentContainer = swiperContainer.closest('.js-slideshow-container');
      const containerForPagination = parentContainer || swiperContainer;
      const fractionEl = containerForPagination.querySelector('.js-swiper-slideshow-pagination');
      const bulletsEl = containerForPagination.querySelector('.js-swiper-slideshow-pagination-bullets');
      const prevArrow = swiperContainer.querySelector('.js-swiper-slideshow-prev') ||
                       (parentContainer ? parentContainer.querySelector('.js-swiper-slideshow-prev') : null);
      const nextArrow = swiperContainer.querySelector('.js-swiper-slideshow-next') ||
                       (parentContainer ? parentContainer.querySelector('.js-swiper-slideshow-next') : null);
      const hasNavigation = prevArrow && nextArrow;

      // Create Swiper instance

      var slideCount = swiperContainer.querySelectorAll('.swiper-slide').length;
      var needsLoop = slideCount > 1;

      // Prevent Swiper from loading images hidden by responsive classes (e.g. desktop img on mobile).
      // Runs before init so clones also inherit the stripped class.
      swiperContainer.querySelectorAll('.swiper-lazy').forEach(function(img) {
        if (getComputedStyle(img).display === 'none') {
          img.classList.remove('swiper-lazy');
        }
      });

      const swiperParams = {
        loop: needsLoop,
        watchOverflow: true,
        lazy: true,
        preloadImages: false,
        pagination: bulletsEl ? { el: bulletsEl, clickable: true } : false,
        navigation: hasNavigation ? {
          nextEl: nextArrow,
          prevEl: prevArrow
        } : false,
        on: {
          slideChangeTransitionEnd: function() {
            if (fractionEl) {
              const currentEl = fractionEl.querySelector('.swiper-pagination-current');
              if (currentEl) currentEl.textContent = this.realIndex + 1;
            }
          }
        }
      };

        // Autoplay is deferred to first interaction on mobile to avoid interfering with LCP.
      const autoplayCallback = deferAutoplay && needsLoop ? function(swiper) {
        deferOnMobile(function() {
          swiper.params.autoplay = { delay: speed, disableOnInteraction: false };
          swiper.autoplay.start();
        });
      } : null;

      // Defer Swiper init until the container is near the viewport to avoid loading off-screen images.
      if (deferInit && 'IntersectionObserver' in window) {
        new IntersectionObserver(function(entries, obs) {
          if (!entries[0].isIntersecting) return;
          obs.disconnect();
          createSwiper(swiperContainer, swiperParams, autoplayCallback);
        }, { rootMargin: '200px' }).observe(swiperContainer);
      } else {
        createSwiper(swiperContainer, swiperParams, autoplayCallback);
      }
    });

    // Featured products sliders
    document.querySelectorAll('.js-products-list-slider').forEach(function(section) {
      const wrapper = section.querySelector('.js-swiper-products-slider');
      if (wrapper) {
        const slider = wrapper.closest('.js-products-list-swiper');
        if (slider) {
          initProductSliderByElement(slider, wrapper);
        }
      }
    });

    function initProductSliderByElement(slider, wrapper) {
      if (!slider || slider.swiper) return;

      // Resolve navigation, pagination and columns from data attributes

      const desktopFormat = wrapper ? wrapper.dataset.desktopFormat : 'slider';
      const mobileFormat = wrapper ? wrapper.dataset.mobileFormat : 'slider';
      const mobileOnly = mobileFormat === 'slider' && desktopFormat !== 'slider';
      const desktopOnly = desktopFormat === 'slider' && mobileFormat !== 'slider';

      if (mobileOnly && window.innerWidth >= 768) return;
      if (desktopOnly && window.innerWidth < 768) return;

      let columnsDesktop = 5;
      let columnsMobile = 2;
      
      if (wrapper && wrapper.dataset.desktopColumns) {
        columnsDesktop = parseInt(wrapper.dataset.desktopColumns, 10) || 5;
        columnsMobile = parseInt(wrapper.dataset.mobileColumns, 10) || 2;
      }

      const parentContainer = slider.closest('.js-products-list-slider-container');
      const slideCount = slider.querySelectorAll('.swiper-slide').length;
      const needsLoop = slideCount > columnsDesktop;

      // Create Swiper instance

      createSwiper(slider, {
        lazy: true,
        slidesPerView: columnsMobile,
        spaceBetween: 16,
        loop: needsLoop,
        watchOverflow: true,
        watchSlidesVisibility: true,
        slideVisibleClass: 'js-swiper-slide-visible',
        navigation: {
          nextEl: parentContainer ? parentContainer.querySelector('.js-swiper-products-list-next') : null,
          prevEl: parentContainer ? parentContainer.querySelector('.js-swiper-products-list-prev') : null
        },
        pagination: {
          el: slider.querySelector('.js-swiper-products-list-pagination'),
          clickable: true
        },
        breakpoints: {
          768: {
            slidesPerView: columnsDesktop,
            slidesPerGroup: columnsDesktop
          }
        },
        on: {
          paginationUpdate: function() { hideSingleBulletPagination(slider); }
        }
      });
    }

    // Testimonials slider
    document.querySelectorAll('.js-testimonials-slider').forEach(function(container) {
      if (container.swiper) return;

      // Resolve navigation, pagination and columns from data attributes

      const wrapper = container.closest('.js-testimonials-slider-container') || container.parentElement;
      const paginationEl = wrapper.querySelector('.js-swiper-testimonials-pagination');
      const columnsDesktop = parseInt(wrapper.dataset.columnsDesktop, 10) || 3;
      const rawGap = parseInt(wrapper.dataset.gap, 10);
      const gapValue = Number.isFinite(rawGap) ? rawGap : 48;

      // Create Swiper instance

      createSwiper(container, {
        lazy: true,
        slidesPerView: 1,
        spaceBetween: gapValue,
        watchOverflow: true,
        pagination: paginationEl ? { el: paginationEl, clickable: true } : false,
        navigation: {
          nextEl: wrapper.querySelector('.js-swiper-testimonials-next'),
          prevEl: wrapper.querySelector('.js-swiper-testimonials-prev')
        },
        breakpoints: {
          768: { slidesPerView: Math.min(2, columnsDesktop), spaceBetween: gapValue },
          1024: { slidesPerView: columnsDesktop, spaceBetween: gapValue }
        },
        on: {
          paginationUpdate: function() { hideSingleBulletPagination(wrapper); }
        }
      }, function() { hideSingleBulletPagination(wrapper); });
    });

    // Carousel slider
    document.querySelectorAll('.js-carousel-slider').forEach(function(container) {
      if (container.swiper) return;
      
      const section = container.closest('.js-carousel-section');
      if (!section) return;

      // Resolve navigation, pagination and columns from data attributes
      
      const columnsMode = container.dataset.columnsMode || 'auto';
      const columnsDesktop = parseInt(container.dataset.columnsDesktop, 10) || 4;
      const columnsMobile = parseInt(container.dataset.columnsMobile, 10) || 2;
      let slideGap = parseInt(container.dataset.slideGap, 10);
      if (isNaN(slideGap)) slideGap = 24;
      const prevBtn = section.querySelector('.js-carousel-prev');
      const nextBtn = section.querySelector('.js-carousel-next');
      const paginationEl = section.querySelector('.js-carousel-pagination');
      
      const centerSlides = container.dataset.centerSlides !== 'false';

      const swiperConfig = {
        lazy: true,
        spaceBetween: slideGap,
        watchOverflow: true,
        centerInsufficientSlides: centerSlides,
        navigation: { nextEl: nextBtn, prevEl: prevBtn },
        pagination: paginationEl ? { el: paginationEl, clickable: true } : false
      };

      // Set slides per view based on columns mode

      if (columnsMode === 'fixed') {
        swiperConfig.slidesPerView = columnsMobile;
        swiperConfig.breakpoints = {
          768: { slidesPerView: Math.min(columnsDesktop, 3), spaceBetween: slideGap },
          1024: { slidesPerView: columnsDesktop, spaceBetween: slideGap }
        };
      } else {
        swiperConfig.slidesPerView = 'auto';
      }

      // Create Swiper instance

      createSwiper(container, swiperConfig);
    });

    // Banners slider
    document.querySelectorAll('.js-banners-slider').forEach(function(container) {
      if (container.swiper) return;
      
      const wrapper = container.closest('.js-banners-slider-container') || container.parentElement;

      // Resolve viewport format from data attributes

      const desktopFormat = wrapper ? wrapper.dataset.desktopFormat : 'slider';
      const mobileFormat = wrapper ? wrapper.dataset.mobileFormat : 'slider';
      const mobileOnly = mobileFormat === 'slider' && desktopFormat !== 'slider';
      const desktopOnly = desktopFormat === 'slider' && mobileFormat !== 'slider';

      if (mobileOnly && window.innerWidth >= 768) return;
      if (desktopOnly && window.innerWidth < 768) return;

      const paginationEl = wrapper ? wrapper.querySelector('.js-swiper-banners-pagination') : container.querySelector('.js-swiper-banners-pagination');

      // Resolve columns and gap from data attributes

      let columnsDesktop = 3;
      let columnsMobile = 1;
      let gapHorizontal = 16;
      if (wrapper && wrapper.dataset.columnsDesktop) {
        columnsDesktop = parseInt(wrapper.dataset.columnsDesktop, 10) || 3;
        columnsMobile = parseInt(wrapper.dataset.columnsMobile, 10) || 1;
      }
      if (wrapper && wrapper.dataset.gapHorizontal !== undefined) {
        gapHorizontal = parseInt(wrapper.dataset.gapHorizontal, 10);
        if (isNaN(gapHorizontal)) gapHorizontal = 16;
      }

      const slideCount = container.querySelectorAll('.swiper-slide').length;
      const needsLoop = slideCount > columnsDesktop;

      // Create Swiper instance
      
      createSwiper(container, {
        lazy: true,
        slidesPerView: columnsMobile,
        spaceBetween: gapHorizontal,
        loop: needsLoop,
        watchOverflow: true,
        pagination: paginationEl ? { el: paginationEl, clickable: true } : false,
        navigation: {
          nextEl: wrapper ? wrapper.querySelector('.js-swiper-banners-next') : container.querySelector('.js-swiper-banners-next'),
          prevEl: wrapper ? wrapper.querySelector('.js-swiper-banners-prev') : container.querySelector('.js-swiper-banners-prev')
        },
        breakpoints: {
          768: { slidesPerView: Math.min(columnsDesktop, 3), spaceBetween: gapHorizontal },
          1024: { slidesPerView: columnsDesktop, spaceBetween: gapHorizontal }
        },
        on: {
          paginationUpdate: function() { hideSingleBulletPagination(wrapper); }
        }
      }, function() { hideSingleBulletPagination(wrapper); });
    });

    // Icon text slider (mobile only)
    document.querySelectorAll('.js-icon-text-slider').forEach(function(container) {
      if (container.swiper) return;
      if (window.innerWidth >= 768) return;

      const wrapper = container.closest('.js-icon-text-slider-container') || container.parentElement;
      const paginationEl = wrapper.querySelector('.js-swiper-icon-text-pagination');
      const parsed = parseInt(wrapper.dataset.gap, 10);
      const gap = isNaN(parsed) ? 20 : parsed;

      createSwiper(container, {
        lazy: true,
        slidesPerView: 1,
        spaceBetween: gap,
        watchOverflow: true,
        pagination: paginationEl ? { el: paginationEl, clickable: true } : false,
        on: {
          paginationUpdate: function() { hideSingleBulletPagination(wrapper); }
        }
      }, function() { hideSingleBulletPagination(wrapper); });
    });

  }

  /**
   * Updates .js-hours, .js-minutes, .js-seconds inside a container with the remaining time.
   * Days are accumulated into hours.
   */
  function updateCountdownDisplay(container, timeLeftSeconds) {
    if (timeLeftSeconds < 0) return;

    const hours = Math.floor(timeLeftSeconds / 3600);
    const minutes = Math.floor((timeLeftSeconds % 3600) / 60);
    const seconds = Math.floor(timeLeftSeconds % 60);

    const hourEl = container.querySelector('.js-hours');
    const minutesEl = container.querySelector('.js-minutes');
    const secondsEl = container.querySelector('.js-seconds');

    if (hourEl) hourEl.textContent = String(hours).padStart(2, '0');
    if (minutesEl) minutesEl.textContent = String(minutes).padStart(2, '0');
    if (secondsEl) secondsEl.textContent = String(seconds).padStart(2, '0');
  }

  /**
   * Auto-discovers .js-countdown elements and starts a 1s interval for each.
   * Expects data-end attribute with a parseable date string.
   */
  function initCountdown() {
    document.querySelectorAll('.js-countdown').forEach(function(el) {
      const endDate = new Date(el.dataset.end).getTime();

      function updateTimer() {
        const distanceMs = endDate - Date.now();
        if (distanceMs < 0) return;
        updateCountdownDisplay(el, Math.floor(distanceMs / 1000));
      }

      updateTimer();
      setInterval(updateTimer, 1000);
    });
  }

  /**
   * Timer Offers Countdown
   * Handles the timer offers section visibility and countdown based on start/end timestamps.
   * Supports multiple timer-offers sections on the same page.
   */
  function initTimerOffers() {

    const timezoneOffsets = {
      'America/Argentina/Buenos_Aires': -3 * 3600,
      'America/Sao_Paulo': -3 * 3600,
      'America/Mexico_City': -6 * 3600,
      'America/Bogota': -5 * 3600,
      'America/Santiago': -4 * 3600,
      'UTC': 0
    };

    // Loop through all timer offers sections

    document.querySelectorAll('.js-timer-offers-section').forEach(function(sectionWrapper) {
      const timerContainer = sectionWrapper.querySelector('.js-timer-offers-container');
      if (!timerContainer) return;

      const isPreview = timerContainer.dataset.preview === 'true';

      // Resolve start and end timestamps from data attributes and local store timezone
      const startTimestamp = parseInt(timerContainer.dataset.startTimestamp, 10);
      const endTimestamp = parseInt(timerContainer.dataset.endTimestamp, 10);
      const timezone = timerContainer.dataset.timezone;

      // If start or end timestamp is not valid, return

      if (!startTimestamp || !endTimestamp || isNaN(startTimestamp) || isNaN(endTimestamp)) {
        return;
      }

      const timezoneOffset = timezoneOffsets[timezone] || 0;

      function getCurrentTimestamp() {
        return Math.floor(Date.now() / 1000) + timezoneOffset;
      }

      let sectionVisible = false;
      let countdownInterval;

      function updateCountdown() {
        const currentTimestamp = getCurrentTimestamp();
        const timeLeft = endTimestamp - currentTimestamp;

        // If time left is less than 0, stop the countdown

        if (timeLeft <= 0) {
          if (!isPreview) sectionWrapper.style.display = 'none';
          clearInterval(countdownInterval);
          return;
        }

        // If current timestamp is less than start timestamp, hide the section

        if (currentTimestamp < startTimestamp) {
          if (!isPreview) sectionWrapper.style.display = 'none';
          return;
        }

        // If section is not visible, show it and initialize the swiper

        if (!sectionVisible) {
          sectionWrapper.style.display = '';
          sectionVisible = true;
          initTimerOffersSwiper(sectionWrapper);
        }

        updateCountdownDisplay(timerContainer, timeLeft);
      }

      countdownInterval = setInterval(updateCountdown, 1000);
      updateCountdown();
    });
  }

  /**
   * Timer Offers Products Swiper
   * Initializes the product carousel for a single timer-offers section.
   * Defers init with double rAF so layout is ready after section becomes visible (avoids wrong width / broken slider).
   * @param {HTMLElement} sectionWrapper - The .js-timer-offers-section element to scope the swiper to
   */
  function initTimerOffersSwiper(sectionWrapper) {
    if (!sectionWrapper) return;

    const swiperContainer = sectionWrapper.querySelector('.js-swiper-timer-offers');
    if (!swiperContainer || swiperContainer.swiper) return;

    // Defer init with double rAF so layout is ready after section becomes visible (avoids wrong width / broken slider)
    requestAnimationFrame(function() {
      requestAnimationFrame(function() {
        if (!swiperContainer.swiper) {
          const slides = swiperContainer.querySelectorAll('.swiper-slide');
          const columnsMobile = 1.75;
          const columnsDesktop = 3;
          const hasEnoughSlides = slides.length > columnsDesktop;
          const nextEl = sectionWrapper.querySelector('.js-swiper-timer-offers-next');
          const prevEl = sectionWrapper.querySelector('.js-swiper-timer-offers-prev');
          const paginationEl = sectionWrapper.querySelector('.js-swiper-timer-offers-pagination');
          const hasNavigation = nextEl && prevEl;

          // Create Swiper instance

          createSwiper(swiperContainer, {
            lazy: true,
            slidesPerView: columnsMobile,
            spaceBetween: 16,
            watchOverflow: true,
            centerInsufficientSlides: true,
            threshold: 5,
            watchSlidesProgress: true,
            watchSlidesVisibility: true,
            slideVisibleClass: 'js-swiper-slide-visible',
            loop: hasEnoughSlides,
            navigation: hasNavigation ? {
              nextEl: nextEl,
              prevEl: prevEl
            } : false,
            pagination: paginationEl ? {
              el: paginationEl,
              clickable: true
            } : false,
            breakpoints: {
              768: {
                slidesPerView: columnsDesktop,
                slidesPerGroup: columnsDesktop
              }
            }
          });
        }
      });
    });
  }

  /**
   * Video Blocks
   * Handles autoplay (via IntersectionObserver) and manual play for video blocks.
   */
  function initVideoBlocks() {
    document.querySelectorAll('.js-video-block').forEach((videoBlock, index) => {
      const videoId = videoBlock.dataset.videoId;
      const videoType = videoBlock.dataset.videoType;
      const videoProvider = videoBlock.dataset.videoProvider || 'youtube';
      const isPriority = videoBlock.dataset.priority === 'true';

      if (!videoId) return;

      const iframeContainer = videoBlock.querySelector('.js-video-iframe');
      const thumbnail = videoBlock.querySelector('.js-video-thumbnail');
      const section = videoBlock.closest('.js-video-section');
      const playButton = videoBlock.querySelector('.js-video-play-button') || (section && section.querySelector('.js-video-play-button'));
      const pauseButton = videoBlock.querySelector('.js-video-pause-button') || (section && section.querySelector('.js-video-pause-button'));
      let currentIframe = null;

      function insertIframe(src, allow) {
        const iframe = document.createElement('iframe');
        iframe.src = src;
        iframe.setAttribute('frameborder', '0');
        iframe.setAttribute('allow', allow);
        iframeContainer.innerHTML = '';
        iframeContainer.appendChild(iframe);
        return iframe;
      }

      function hideThumbnail() {
        fadeOut(thumbnail);
      }

      function vimeoPost(method, value) {
        if (!currentIframe || !currentIframe.contentWindow) return;
        const msg = value !== undefined ? { method, value } : { method };
        currentIframe.contentWindow.postMessage(JSON.stringify(msg), '*');
      }

      function observeViewport(callback) {
        const obs = new IntersectionObserver((entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              callback();
              obs.disconnect();
            }
          });
        }, { threshold: 0, rootMargin: '0px 0px 200px 0px' });
        obs.observe(videoBlock);
      }

      // Vimeo without cover/thumbnail: fetch via oEmbed when near viewport
      if (videoProvider === 'vimeo' && videoId && thumbnail && thumbnail.style.display === 'none') {
        observeViewport(function() {
          const thumbImg = thumbnail.querySelector('img');
          fetch('https://vimeo.com/api/oembed.json?url=' + encodeURIComponent('https://vimeo.com/' + videoId))
            .then(r => r.json())
            .then(data => {
              if (data && data.thumbnail_url && thumbImg) {
                const hdUrl = data.thumbnail_url.replace(/_\d+x\d+/, '_1280x720');
                thumbImg.onload = () => fadeIn(thumbnail);
                thumbImg.srcset = '';
                thumbImg.src = hdUrl;
              }
            });
        });
      }

      // Video loading

      function loadVideo(isAutoplay) {
        if (videoProvider === 'vimeo') {
          // background=1 removes all native Vimeo UI (controls, title, etc.)
          const iframe = insertIframe(
            'https://player.vimeo.com/video/' + videoId + '?autoplay=1&playsinline=1&background=1&dnt=1',
            'autoplay; fullscreen'
          );
          currentIframe = iframe;

          if (isAutoplay) {
            iframe.addEventListener('load', () => hideThumbnail());
          }
          // Manual: load handler is set by the play button click
          return;
        }

        // YouTube: prefer YT.Player API for loop-via-seekTo and mute-via-API
        const playerVars = {
          autoplay: 1,
          playsinline: 1,
          rel: 0,
          controls: 0,
          showinfo: 0,
          modestbranding: 1,
          branding: 0,
          fs: 0,
          iv_load_policy: 3,
          cc_load_policy: 0
        };

        if (isAutoplay) {
          playerVars.loop = 1;
          playerVars.autopause = 0;
        }

        if (window.youtubeIframeService) {
          const playerId = 'yt-player-' + videoId + '-' + index;
          const playerDiv = document.createElement('div');
          playerDiv.id = playerId;
          iframeContainer.innerHTML = '';
          iframeContainer.appendChild(playerDiv);

          window.youtubeIframeService.executeOnReady(() => {
            new YT.Player(playerId, {
              width: '100%',
              videoId: videoId,
              playerVars: playerVars,
              events: {
                onReady: (event) => {
                  if (isAutoplay) event.target.mute();
                  event.target.playVideo();
                },
                onApiChange: (event) => {
                  try {
                    event.target.setOption('captions', 'track', {});
                    event.target.unloadModule('captions');
                  } catch (e) {}
                },
                onStateChange: (event) => {
                  if (event.data === YT.PlayerState.PLAYING) hideThumbnail();
                  if (isAutoplay && event.data === YT.PlayerState.ENDED) {
                    event.target.seekTo(0);
                    event.target.playVideo();
                  }
                }
              }
            });
          });
        } else {
          let params = 'autoplay=1&playsinline=1&rel=0&controls=0&showinfo=0&modestbranding=1&branding=0&fs=0&iv_load_policy=3&cc_load_policy=0';
          if (isAutoplay) params += '&mute=1&loop=1&playlist=' + videoId;
          const iframe = insertIframe(
            'https://www.youtube.com/embed/' + videoId + '?' + params,
            'autoplay; encrypted-media'
          );
          iframe.addEventListener('load', () => hideThumbnail());
        }
      }

      // Autoplay: load on viewport intersection

      if (videoType === 'autoplay') {
        if (isPriority) {
          deferOnMobile(function() { loadVideo(true); });
        } else {
          observeViewport(function() { loadVideo(true); });
        }
      }

      // Manual mode: provider-specific play/pause

      if (videoType === 'manual' && playButton) {
        if (videoProvider === 'vimeo') {
          let pauseAutoHide;

          // Play: load iframe (or resume), unmute, fade out button, hide thumbnail
          playButton.addEventListener('click', (e) => {
            e.preventDefault();
            if (currentIframe) {
              vimeoPost('setVolume', 1);
              vimeoPost('play');
            } else {
              loadVideo(false);
              // Wait for Vimeo player ready event, then unmute and play
              window.addEventListener('message', function onReady(msg) {
                if (msg.source !== currentIframe.contentWindow) return;
                if (typeof msg.data !== 'string' || msg.data.indexOf('"ready"') === -1) return;
                const data = JSON.parse(msg.data);
                if (data.event === 'ready') {
                  window.removeEventListener('message', onReady);
                  vimeoPost('setLoop', false);
                  vimeoPost('setVolume', 1);
                  vimeoPost('play');
                }
              });
            }
            fadeOut(playButton);
            hideThumbnail();
          });

          // Overlay click: show pause button with auto-hide
          const overlay = videoBlock.querySelector('.video-block-hide-controls');
          if (overlay && pauseButton) {
            overlay.addEventListener('click', () => {
              if (pauseButton.style.display === 'none') {
                fadeIn(pauseButton);
                clearTimeout(pauseAutoHide);
                pauseAutoHide = setTimeout(() => fadeOut(pauseButton), 3000);
              }
            });
          }

          // Pause: pause video + show play
          if (pauseButton) {
            pauseButton.addEventListener('click', (e) => {
              e.preventDefault();
              clearTimeout(pauseAutoHide);
              vimeoPost('pause');
              fadeOut(pauseButton);
              fadeIn(playButton);
            });
          }

        } else {
          // YouTube: click play, load video, fade out and remove buttons
          playButton.addEventListener('click', (e) => {
            e.preventDefault();
            loadVideo(false);
            fadeOut(playButton);
            if (pauseButton) pauseButton.remove();
          });
        }
      }
    });
  }

  /**
   * Promotional Modal
   *
   * Show-once + open/close goes through the platform helpers:
   *   - LS.homePopup handles the cookie + timeout (despite the name it's a
   *     generic helper, not coupled to the home page).
   *   - modalHandler.modalOpen / modalClose drive the visual show/hide so we
   *     don't fake clicks on .js-modal-close-private to dismiss.
   */
  const PROMOTIONAL_MODAL_ID = '#promotional-modal';

  function wirePromotionalModalNewsletter(modal) {
    const form = modal.querySelector('.js-newsletter-form-ajax');
    if (!form) return;

    const submitBtn = form.querySelector('.js-newsletter-form-submit');
    const spinner = submitBtn && submitBtn.querySelector('.js-newsletter-form-spinner');
    const successAlert = form.querySelector('.js-newsletter-success-alert');
    const errorAlert = form.querySelector('.js-newsletter-error-alert');

    function setLoading(loading) {
      if (submitBtn) submitBtn.disabled = loading;
      if (spinner) spinner.style.display = loading ? '' : 'none';
    }

    form.addEventListener('submit', function() { setLoading(true); });

    LS.newsletter(
      form.closest('.js-newsletter-form-wrapper'),
      PROMOTIONAL_MODAL_ID,
      modal.dataset.contactUrl,
      function(response) {
        setLoading(false);
        if (response.success) {
          if (successAlert) { fadeIn(successAlert); setTimeout(function() { fadeOut(successAlert); }, 4000); }
          setTimeout(function() { modalHandler.modalClose(PROMOTIONAL_MODAL_ID); }, 2500);
        } else {
          if (errorAlert) { fadeIn(errorAlert); setTimeout(function() { fadeOut(errorAlert); }, 4000); }
        }
      }
    );
  }

  function initPromotionalModal() {
    // Skip auto-show in any embedded preview (Brand Editor, admin previews):
    // the modal is intrusive there. A future "preview-modal" feature will
    // open it programmatically when the user is editing this category.
    if (window.parent !== window) return;

    const modal = document.querySelector(PROMOTIONAL_MODAL_ID);
    if (!modal) return;
    if (modal.dataset.newsletterSuccess === 'true') return;

    LS.homePopup({
      selector: PROMOTIONAL_MODAL_ID,
      cookie_name: 'promotional-modal',
      cookie_expiration_days: 30,
      mobile_max_pixels: 0,
      timeout: 10000,
    }, null, function() {
      modalHandler.modalOpen(PROMOTIONAL_MODAL_ID);
      wirePromotionalModalNewsletter(modal);
    });
  }

  /**
   * Announcement Bar
   * Initializes marquee animation and slider functionality for announcement bars.
   */
  function initAdbar() {
    // Marquee
    const marquees = document.querySelectorAll('.js-adbar-marquee');
    marquees.forEach(function(marquee) {
      const content = marquee.querySelector('.js-adbar-marquee-content');
      if (!content) return;
      
      // Resolve speed from data attribute
      const speed = parseInt(marquee.getAttribute('data-speed') || 5);
      const duration = Math.max(10, 50 - (speed * 4));
      const direction = marquee.getAttribute('data-direction') || 'left';
      
      const track = document.createElement('div');
      track.className = 'adbar-marquee-track';
      if (direction === 'right') {
        track.classList.add('adbar-marquee-track-reverse');
      }
      track.style.setProperty('--marquee-duration', duration + 's');
      
      marquee.appendChild(track);
      track.appendChild(content);
      
      const contentWidth = content.offsetWidth;
      const screenWidth = window.innerWidth;

      if (contentWidth > 0 && contentWidth < screenWidth) {
        const items = content.querySelectorAll('.js-adbar-item');
        const itemsArray = Array.prototype.slice.call(items);
        const duplicatesNeeded = Math.ceil(screenWidth / contentWidth);
        for (let d = 0; d < duplicatesNeeded; d++) {
          itemsArray.forEach(function(item) {
            content.appendChild(item.cloneNode(true));
          });
        }
      }
      
      // Clone the content and append it to the track

      const clone = content.cloneNode(true);
      track.appendChild(clone);
    });

    // Slider
    document.querySelectorAll('.js-adbar-slider').forEach(function(slider) {
      const autoplay = slider.getAttribute('data-autoplay') === 'true';
      const speed = parseInt(slider.getAttribute('data-speed') || 5);
      const delay = Math.max(2000, 9000 - (speed * 700));
      const nextEl = slider.querySelector('.js-adbar-slider-next');
      const prevEl = slider.querySelector('.js-adbar-slider-prev');
      const hasNavigation = nextEl && prevEl;
      const hasEnoughSlides = slider.querySelectorAll('.js-adbar-slide').length > 1;

      createSwiper(slider, {
        slidesPerView: 1,
        loop: hasEnoughSlides,
        watchOverflow: true,
        autoplay: (autoplay && hasEnoughSlides) ? { delay: delay, disableOnInteraction: false, pauseOnMouseEnter: true } : false,
        navigation: hasNavigation ? { nextEl: nextEl, prevEl: prevEl } : false
      });
    });
  }


  /* ========================================
   * SHOPPING EXPERIENCE - CORE
   * ======================================== 
   * Core UI components: header, navigation, footer, modals, accordions
   * - Sticky header
   * - Mobile navigation
   * - Desktop navigation
   * - Nav toggles
   * - Footer toggles
   * - Slim header on scroll
   */

  /**
   * Sticky Header
   * Makes the header stick to top on scroll. Announcements above the header
   * are included in the sticky group and hidden on scroll down to save space.
   * Announcements below the header scroll away naturally.
   */
  function initStickyHeader() {
    const headerGroup = document.querySelector('.js-header');
    if (!headerGroup) return;

    // Check if sticky is enabled via the header's data attribute
    const header = headerGroup.querySelector('.js-head-main');
    if (!header) return;

    if (header.getAttribute('data-sticky-header') !== 'true') {
      headerGroup.classList.add('sticky-disabled');
      return;
    }

    // Classify sections in the header group relative to the header
    const sectionWrappers = headerGroup.querySelectorAll('[data-section-type]');
    const sectionsAbove = [];
    const sectionsBelow = [];

    sectionWrappers.forEach(function(wrapper) {
      const type = wrapper.getAttribute('data-section-type');
      if (type === 'header') return;

      const position = header.compareDocumentPosition(wrapper);
      if (position & Node.DOCUMENT_POSITION_PRECEDING) {
        sectionsAbove.push(wrapper);
      } else if (position & Node.DOCUMENT_POSITION_FOLLOWING) {
        sectionsBelow.push(wrapper);
      }
    });

    // Skip DOM restructuring if there are no announcements
    const hasAnnouncements = sectionsAbove.length > 0 || sectionsBelow.length > 0;

    // Wrap sticky sections (announcements above + header) and create a placeholder to prevent layout shift
    const stickyWrapper = document.createElement('div');
    stickyWrapper.className = 'sticky-header-wrapper';

    const placeholder = document.createElement('div');
    placeholder.className = 'sticky-header-placeholder';

    sectionsAbove.forEach(function(section) {
      stickyWrapper.appendChild(section);
    });

    stickyWrapper.appendChild(header);

    headerGroup.insertBefore(placeholder, headerGroup.firstChild);
    headerGroup.insertBefore(stickyWrapper, placeholder.nextSibling);

    // Move announcements below the header to a non-sticky container
    if (sectionsBelow.length > 0) {
      const staticContainer = document.createElement('div');
      staticContainer.className = 'static-announcements';
      sectionsBelow.forEach(function(section) {
        staticContainer.appendChild(section);
      });
      headerGroup.appendChild(staticContainer);
    }

    let lastScrollY = window.scrollY;
    let isFixed = false;
    let isHidden = false;
    const scrollThreshold = 10;
    const hideThreshold = 100;

    // Calculate combined height of announcements above the header for CSS offset
    function updateAnnouncementsHeight() {
      let total = 0;
      sectionsAbove.forEach(function(el) {
        total += el.offsetHeight || 0;
      });
      stickyWrapper.style.setProperty('--announcements-height-negative', '-' + total + 'px');
    }

    if (sectionsAbove.length > 0) {
      updateAnnouncementsHeight();
    }

    // Recalculate dimensions on resize
    let resizeTimer;
    window.addEventListener('resize', function() {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(function() {
        if (sectionsAbove.length > 0) {
          updateAnnouncementsHeight();
        }
        if (!isFixed) {
          originalTop = stickyWrapper.getBoundingClientRect().top + window.scrollY;
        }
        if (isFixed) {
          placeholder.style.height = stickyWrapper.offsetHeight + 'px';
        }
      }, 100);
    });

    let originalTop = stickyWrapper.getBoundingClientRect().top + window.scrollY;

    // Recalculate originalTop when external elements modify the layout (e.g., admin bar iframe)
    function recalcOriginalTop() {
      if (!isFixed) {
        originalTop = stickyWrapper.getBoundingClientRect().top + window.scrollY;
      }
    }

    new MutationObserver(recalcOriginalTop).observe(document.documentElement, {
      attributes: true, attributeFilter: ['style', 'class']
    });
    new MutationObserver(recalcOriginalTop).observe(document.body, {
      childList: true, attributes: true, attributeFilter: ['style']
    });

    // Toggle fixed positioning and hide announcements on scroll down
    function handleScroll() {
      const currentScrollY = window.scrollY;
      const shouldBeFixed = currentScrollY > originalTop;

      if (shouldBeFixed && !isFixed) {
        placeholder.style.height = stickyWrapper.offsetHeight + 'px';
        placeholder.classList.add('is-active');
        stickyWrapper.classList.add('is-fixed');
        isFixed = true;
      } else if (!shouldBeFixed && isFixed) {
        stickyWrapper.classList.remove('is-fixed');
        placeholder.classList.remove('is-active');
        placeholder.style.height = '0';
        stickyWrapper.classList.remove('hide-announcements');
        isFixed = false;
        isHidden = false;
      }

      // Hide announcements above the header when scrolling down past threshold
      if (isFixed && sectionsAbove.length > 0) {
        const delta = currentScrollY - lastScrollY;

        if (Math.abs(delta) >= scrollThreshold) {
          if (delta > 0 && currentScrollY > hideThreshold && !isHidden) {
            stickyWrapper.classList.add('hide-announcements');
            isHidden = true;
          }
          lastScrollY = currentScrollY;
        }
      }
    }

    // Throttle scroll handler with requestAnimationFrame
    let ticking = false;
    window.addEventListener('scroll', function() {
      if (!ticking) {
        requestAnimationFrame(function() {
          handleScroll();
          ticking = false;
        });
        ticking = true;
      }
    }, { passive: true });
  }

  /**
   * Mobile Navigation Close
   * Makes the main nav panel close instantly when dismissing all sub-level modals.
   */
  function initNavToggles() {
    document.querySelectorAll('.js-close-all-nav-modals').forEach(function(btn) {
      btn.addEventListener('click', function() {
        const navHamburger = document.getElementById('nav-hamburger');
        if (navHamburger) {
          navHamburger.classList.add('modal-transition-fast');
          setTimeout(function() {
            navHamburger.classList.remove('modal-transition-fast');
          }, 1000);
        }
      });
    });
  }

  /**
   * Shared horizontal scroll with arrows
   * Detects overflow, toggles arrow visibility and disable state, binds scroll-by-click.
   *
   * @param {Element} navList - The scrollable list element
   * @param {Element|null} arrowLeft - Left arrow button
   * @param {Element|null} arrowRight - Right arrow button
   * @param {Object} opts
   * @param {string} opts.overflowClass - Class added to navList when overflowing
   * @param {string|null} opts.arrowVisibilityClass - Class toggled on arrows for show/hide (null = use style.display)
   * @param {boolean} opts.listenResize - Whether to recalculate on window resize
   */
  function initScrollableNav(navList, arrowLeft, arrowRight, opts) {
    if (!navList) return;
    var overflowClass = opts.overflowClass || 'has-arrows';
    var listenResize = opts.listenResize || false;
    var onResize = opts.onResize || null;

    function updateArrows() {
      var isDesktop = window.innerWidth >= 768;
      if (!isDesktop) {
        if (arrowLeft) arrowLeft.style.display = 'none';
        if (arrowRight) arrowRight.style.display = 'none';
        navList.classList.remove(overflowClass);
        return;
      }
      var pos = navList.scrollLeft;
      var maxScroll = navList.scrollWidth - navList.clientWidth;
      var overflowing = navList.scrollWidth > navList.clientWidth + 1;
      if (arrowLeft) {
        arrowLeft.style.display = overflowing ? 'flex' : 'none';
        arrowLeft.classList.toggle('disable', pos <= 0);
      }
      if (arrowRight) {
        arrowRight.style.display = overflowing ? 'flex' : 'none';
        arrowRight.classList.toggle('disable', pos >= maxScroll - 1);
      }
      navList.classList.toggle(overflowClass, overflowing);
    }

    navList.addEventListener('scroll', updateArrows);
    if (listenResize) {
      window.addEventListener('resize', function() {
        if (onResize) onResize();
        updateArrows();
      });
    }
    updateArrows();

    if (arrowRight) {
      arrowRight.addEventListener('click', function() {
        navList.scrollBy({ left: 400, behavior: 'smooth' });
      });
    }
    if (arrowLeft) {
      arrowLeft.addEventListener('click', function() {
        navList.scrollBy({ left: -400, behavior: 'smooth' });
      });
    }
  }

  /**
   * Desktop Navigation
   * If nav items overflow the available space, enables horizontal scroll with arrows.
   */
  function initDesktopNav() {
    var navContainer = document.querySelector('.js-nav-desktop-container');
    if (!navContainer) return;

    var navList = navContainer.querySelector('.js-nav-desktop-list');
    if (!navList) {
      revealNav(navContainer);
      return;
    }

    var navCol = navContainer.querySelector('.js-desktop-nav-col');

    function updateNavColWidth() {
      if (navCol) {
        navCol.style.width = '';
        navCol.style.width = navCol.offsetWidth + 'px';
      }
    }

    updateNavColWidth();
    navList.style.whiteSpace = 'nowrap';

    initScrollableNav(
      navList,
      navContainer.querySelector('.js-nav-desktop-list-arrow-left'),
      navContainer.querySelector('.js-nav-desktop-list-arrow-right'),
      { overflowClass: 'nav-desktop-with-scroll', arrowVisibilityClass: null, listenResize: true, onResize: updateNavColWidth }
    );

    revealNav(navContainer);
  }

  function revealNav(container) {
    container.style.visibility = 'visible';
    container.style.height = 'auto';
  }

  function initHeaderDropdownPosition() {
    const margin = 32;

    document.querySelectorAll('.js-header-dropdown').forEach(function(trigger) {
      const dropdown = trigger.querySelector('.js-header-dropdown-content');
      if (!dropdown) return;

      trigger.addEventListener('mouseenter', function() {
        dropdown.style.right = 'auto';
        dropdown.style.left = '50%';
        dropdown.style.transform = 'translateX(-50%)';

        const overflow = dropdown.getBoundingClientRect().right - window.innerWidth + margin;
        if (overflow > 0) {
          dropdown.style.transform = 'translateX(calc(-50% - ' + overflow + 'px))';
        }
      });
    });
  }

  function initDesktopDropdownHeight() {
    var dropdowns = document.querySelectorAll('.js-desktop-dropdown');
    var headerMain = document.querySelector('.js-head-main');
    if (!dropdowns.length || !headerMain) return;

    function updateHeight() {
      var maxHeight = window.innerHeight - headerMain.offsetHeight - 50;
      dropdowns.forEach(function(dropdown) {
        dropdown.style.maxHeight = maxHeight + 'px';
      });
    }

    updateHeight();
    window.addEventListener('resize', updateHeight);
  }

  /**
   * Navigation Bar section
   * Enables horizontal scroll with arrows for each .js-navigation-bar instance.
   */
  function initNavigationBars() {
    var bars = document.querySelectorAll('.js-navigation-bar');
    if (!bars.length) return;

    bars.forEach(function(bar) {
      initScrollableNav(
        bar.querySelector('.js-navigation-bar-list'),
        bar.querySelector('.js-navigation-bar-arrow-left'),
        bar.querySelector('.js-navigation-bar-arrow-right'),
        { overflowClass: 'has-arrows', arrowVisibilityClass: null, listenResize: true }
      );
    });

    injectInMenuNavigationBars();
  }

  /**
   * Move pre-rendered navigation-bar mobile content into the hamburger panel.
   * The HTML is rendered server-side in navigation-bar.tpl as .js-navigation-bar-mobile.
   */
  function injectInMenuNavigationBars() {
    var mount = document.querySelector('.js-navbars-mobile-mount');
    if (!mount) return;

    document.querySelectorAll('.js-navigation-bar-mobile').forEach(function(el) {
      while (el.firstChild) {
        mount.appendChild(el.firstChild);
      }
      el.remove();
    });

    mount.style.display = 'block';
  }

  /**
   * Slim Header on Scroll
   * Reduces header height and hides secondary elements when scrolling down.
   */
  function initSlimHeaderOnScroll() {
    const header = document.querySelector('.js-head-main');
    if (!header) return;
    
    const isSticky = header.dataset.stickyHeader === 'true';
    if (!isSticky) return;
    
    function handleScroll() {
      const scrolledPosition = window.pageYOffset || document.documentElement.scrollTop;
      const navbarHeight = header.offsetHeight;
      
      if (scrolledPosition > navbarHeight) {
        if (!header.classList.contains('compress')) {
          header.classList.add('compress');
        }
      } else {
        if (header.classList.contains('compress')) {
          header.classList.remove('compress');
        }
      }
    }
    
    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll();
  }

  // Unified search trigger: desktop expands inline form, mobile opens modal.
  function initSearchTrigger() {
    const isDesktop = window.matchMedia('(min-width: 768px)');

    document.querySelectorAll('.js-search-trigger').forEach(trigger => {
      trigger.addEventListener('click', () => {
        if (isDesktop.matches) {
          // Desktop: expand floating search form
          const container = trigger.closest('.js-search-container');
          if (!container) return;
          const form = container.querySelector('.js-search-expand-form');
          trigger.classList.add('visible');
          trigger.setAttribute('aria-expanded', 'true');
          form.classList.add('visible');
          form.setAttribute('aria-hidden', 'false');
          setTimeout(() => form.querySelector('.js-search-input')?.focus(), 200);
        } else {
          // Mobile: open search modal and focus input
          modalHandler.modalOpen('#modal-search');
          setTimeout(() => {
            document.querySelector('#modal-search .js-search-input')?.focus();
          }, 200);
        }
      });
    });

    // Close desktop search on click outside
    document.addEventListener('click', e => {
      if (e.target.closest('.js-search-container')) return;
      document.querySelectorAll('.js-search-expand-form.visible').forEach(form => {
        form.classList.remove('visible');
        form.setAttribute('aria-hidden', 'true');
        const trigger = form.closest('.js-search-container')
          ?.querySelector('.js-search-trigger');
        trigger?.classList.remove('visible');
        trigger?.setAttribute('aria-expanded', 'false');
      });
    });

    // Close desktop search on Escape key
    document.addEventListener('keydown', e => {
      if (e.key !== 'Escape') return;
      document.querySelectorAll('.js-search-expand-form.visible').forEach(form => {
        form.classList.remove('visible');
        form.setAttribute('aria-hidden', 'true');
        const trigger = form.closest('.js-search-container')
          ?.querySelector('.js-search-trigger');
        trigger?.classList.remove('visible');
        trigger?.setAttribute('aria-expanded', 'false');
      });
    });
  }

  /**
   * Inactive Tab Message
   * Rotates document title with custom messages when the tab is inactive.
   */
  function initInactiveTabMessage() {
    const msg1 = document.body.getAttribute('data-inactive-tab-msg1');
    const msg2 = document.body.getAttribute('data-inactive-tab-msg2');
    const messages = [msg1, msg2].filter(Boolean);
    if (!messages.length) return;

    const originalTitle = document.title;
    let messageIndex = 0;
    let interval;

    document.addEventListener('visibilitychange', function() {
      if (document.hidden) {
        interval = setInterval(function() {
          document.title = messages[messageIndex];
          messageIndex = (messageIndex + 1) % messages.length;
        }, 2000);
      } else {
        clearInterval(interval);
        document.title = originalTitle;
      }
    });
  }

  /* ========================================
   * SHOPPING EXPERIENCE - CATEGORY/SEARCH
   * ======================================== 
   * - Product item sliders
   * - Infinite scroll
   * - Sticky category controls
   * - Quickshop
   */

  /**
   * Product Item Sliders
   * Initializes image sliders on product cards.
   */
  function initProductItemSliders() {
    LS.productItemSlider({ pagination_type: 'fraction' });
  }

  /**
   * Infinite Scroll
   * Loads more products automatically when user scrolls near bottom of category and search page.
   */
  function initInfiniteScroll() {
    const loadMoreBtn = document.querySelector('.js-load-more');
    if (!loadMoreBtn) return;

    LS.hybridScroll({
      productGridSelector: '.js-product-table',
      spinnerSelector: '#js-infinite-scroll-spinner',
      loadMoreButtonSelector: '.js-load-more',
      hideWhileScrollingSelector: '.js-hide-footer-while-scrolling',
      productsBeforeLoadMoreButton: 60,
      productsPerPage: 12,
      afterLoaded: function() {
        LS.productItemSlider({ pagination_type: 'fraction' });
      }
    });
  }

  /**
   * Sticky Category Controls
   * Makes filter and sort controls sticky on category pages while scrolling.
   */
  function initStickyCategoryControls() {
    const categoryControls = document.querySelector('.js-category-controls');
    const categoryControlsPrev = document.querySelector('.js-category-controls-prev');
    const headerMain = document.querySelector('.js-head-main');
    
    if (!categoryControls || !headerMain || window.innerWidth >= 768) return;
    
    function offsetCategories() {
      let headerHeight = headerMain.offsetHeight;
      
      if (headerMain.classList.contains('compress')) {
        const adBars = document.querySelectorAll('.js-ad-bar');
        let adBarsHeight = 0;
        adBars.forEach(function(bar) {
          if (bar.offsetHeight) adBarsHeight += bar.offsetHeight;
        });
        headerHeight = headerHeight - adBarsHeight - 1;
      }
      
      categoryControls.style.top = headerHeight + 'px';
    }
    
    offsetCategories();
    document.addEventListener('scroll', offsetCategories, { passive: true });
    
    if (categoryControlsPrev) {
      const observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
          categoryControls.classList.toggle('is-sticky', !entry.isIntersecting);
        });
      });

      observer.observe(categoryControlsPrev);
    }
  }

  // Restores quickshop form to its original list item and resets variant selections
  function restoreQuickshopForm() {
    const quickshopModal = document.querySelector('#quickshop-modal');
    if (!quickshopModal) return;
    
    const container = quickshopModal.querySelector('.js-product-item-private');
    if (container) {
      container.classList.remove('js-swiper-slide-visible', 'js-item-slide');
      container.setAttribute('data-variants', '');
      container.setAttribute('data-quickshop-id', '');
      container.setAttribute('data-product-id', '');
    }

    const variantOptions = quickshopModal.querySelectorAll('.js-variation-option');
    variantOptions.forEach(function(select) {
      if (select.options && select.options.length > 0) {
        select.selectedIndex = 0;
      }
    });
    
    setTimeout(function() {
      const quickshopForm = document.querySelector('#quickshop-form .js-product-form');
      const openedItem = document.querySelector('.js-quickshop-opened');
      
      if (quickshopForm && openedItem) {
        const itemFormContainer = openedItem.querySelector('.js-item-variants');
        if (itemFormContainer) {
          itemFormContainer.appendChild(quickshopForm);
        }
        openedItem.classList.remove('js-quickshop-opened');
      }
      
      const quickshopImg = quickshopModal.querySelector('.js-quickshop-img');
      if (quickshopImg) {
        quickshopImg.setAttribute('srcset', '');
      }
      
      const quickshopFormContainer = document.querySelector('#quickshop-form');
      if (quickshopFormContainer) {
        quickshopFormContainer.removeAttribute('style');
      }
    }, 350);
  }

  /**
   * Quick Shop
   * Handles quick shop modal for adding products without leaving the current page.
   */
  function initQuickshop() {
    // Handle quickshop modal open and close
    document.addEventListener('click', function(e) {
      const btn = e.target.closest('.js-quickshop-modal-open');
      if (btn) {
        e.preventDefault();
        
        if (btn.classList.contains('js-quickshop-slide')) {
          const modal = document.querySelector('#quickshop-modal .js-product-item-private');
          if (modal) {
            modal.classList.add('js-swiper-slide-visible', 'js-item-slide');
          }
        }
        
        const productContainer = btn.closest('.js-product-item-private');
        if (productContainer && window.noStockVariants) {
          window.noStockVariants(productContainer);
        }
        
        LS.fillQuickshop(btn);
      }
      
      const closeBtn = e.target.closest('.js-modal-close-private');
      if (closeBtn) {
        e.preventDefault();
        restoreQuickshopForm();
      }
    });
  }

  /**
   * Product List Variant Handler
   * Updates product card image, destroys slider, and disables secondary image on variant change.
   */
  function initProductListVariantHandler() {
    if (typeof LS.registerOnChangeVariant !== 'function') return;

    LS.registerOnChangeVariant(function(variant) {
      const productContainer = document.querySelector('.js-product-item-private[data-product-id="' + variant.product_id + '"]');
      if (productContainer) {
        const currentImage = productContainer.querySelector('.js-product-item-image-private');
        if (currentImage && variant.image_url) {
          currentImage.setAttribute('srcset', variant.image_url);
        }

        const swiperElement = productContainer.querySelector('.js-product-item-slider-container-private.swiper-container-initialized');
        if (swiperElement) {
          const slides = productContainer.querySelectorAll('.js-product-item-slider-slide-private');
          slides.forEach(function(slide) {
            slide.classList.remove('item-image-slide');
          });

          const visibleSlideImg = productContainer.querySelector('.js-swiper-slide-visible img');

          setTimeout(function() {
            const productImageLink = productContainer.querySelector('.js-product-item-image-link-private');

            let imageToKeep = null;
            if (visibleSlideImg) {
              imageToKeep = visibleSlideImg.cloneNode(true);
              if (variant.image_url) {
                imageToKeep.setAttribute('srcset', variant.image_url);
                imageToKeep.setAttribute('src', variant.image_url);
              }
            }

            if (typeof itemProductSliders !== 'undefined' && itemProductSliders[variant.product_id]) {
              itemProductSliders[variant.product_id].destroy(true, true);
              delete itemProductSliders[variant.product_id];
            }

            swiperElement.remove();
            const paginationContainer = productContainer.querySelector('.js-product-item-slider-pagination-container');
            if (paginationContainer) {
              paginationContainer.remove();
            }

            if (productImageLink && imageToKeep) {
              productImageLink.appendChild(imageToKeep);
            }
          }, 300);
        }

        if (currentImage) {
          const itemWithSecondary = currentImage.closest('.js-item-with-secondary-image');
          if (itemWithSecondary) {
            itemWithSecondary.classList.remove('item-with-two-images');
          }
        }
        const secondaryImagesContainer = productContainer.querySelector('.js-product-item-private-with-secondary-images');
        if (secondaryImagesContainer) {
          secondaryImagesContainer.classList.add('product-item-secondary-images-disabled');
        }
      }

      if (variant.image_url) {
        const quickshopImg = document.querySelector('#quickshop-modal .js-quickshop-img');
        if (quickshopImg) {
          quickshopImg.setAttribute('srcset', variant.image_url);
          quickshopImg.setAttribute('src', variant.image_url);
        }
      }
    });
  }

  /* ========================================
   * SHOPPING EXPERIENCE - PRODUCT (PDP)
   * ======================================== 
   * Product detail page functionality
   * - Product gallery (swiper + fancybox)
   * - Product video
   * - Product variants (change variant, no stock)
   * - Quantity selector
   * - Add to cart
   * - Shipping calculator
   * - Product recommendations
   * - Free shipping progress
   */

  // Guards the non-idempotent parts of initProductGallery (document-level
  // click delegation and Fancybox bind). Brand Editor's preview re-runs this
  // init on every morph so new product galleries get a Swiper; the Swiper
  // branches already guard on `container.swiper`, but the delegated listener
  // and Fancybox bind would accumulate handlers without this flag.
  var productGalleryDelegatesBound = false;

  /**
   * Product Gallery
   * Initializes product image gallery with thumbnails, zoom, and variant image switching.
   */

  /**
   * Sticky Product Gallery
   * Avoids empty whitespace when scrolling the images or info column.
   */
  function initStickyProductGallery() {
    const images = document.querySelector('.js-product-images');
    const info = document.querySelector('.js-product-info');
    if (!images || !info) return;

    // Matches .product-images' CSS: keeps natural height instead of stretching, so info can stick too.
    info.style.alignSelf = 'flex-start';

    const isDesktop = window.matchMedia('(min-width: 768px)');
    const stickyHeaderEl = document.querySelector('.sticky-header-wrapper');

    function reset(el) {
      el.style.position = '';
      el.style.top = '';
    }

    function stick(shortEl) {
      const headerOffset = stickyHeaderEl ? stickyHeaderEl.offsetHeight : 0;
      const bottomAnchoredTop = window.innerHeight - shortEl.offsetHeight;

      // Whichever offset is smaller wins: header pin when the column fits,
      // bottom anchor (often negative) when it's taller than the viewport.
      shortEl.style.position = 'sticky';
      shortEl.style.top = Math.min(headerOffset, bottomAnchoredTop) + 'px';
    }

    function measure() {
      reset(images);
      reset(info);

      if (!isDesktop.matches) return;

      if (info.offsetHeight > images.offsetHeight) {
        stick(images);
      } else if (images.offsetHeight > info.offsetHeight) {
        stick(info);
      }
    }

    measure();

    let resizeTimer;
    window.addEventListener('resize', function() {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(measure, 100);
    });

    // Re-measure if either column's height changes (variant selection, grid format/columns, etc.)
    new ResizeObserver(measure).observe(info);
    new ResizeObserver(measure).observe(images);
  }

  function initProductGallery() {
    // Main product image slider
    document.querySelectorAll('.js-product-slider').forEach(function(container) {
      if (container.swiper) return;
      
      const parentMedia = container.closest('.js-product-images') || container.closest('.product-images');
      const prevArrow = container.querySelector('.js-product-slider-prev');
      const nextArrow = container.querySelector('.js-product-slider-next');
      const hasNavigation = prevArrow && nextArrow;
      
      createSwiper(container, {
        slidesPerView: 1,
        spaceBetween: 0,
        lazy: true,
        pagination: {
          el: container.querySelector('.js-product-slider-pagination') || container.parentElement.querySelector('.js-product-slider-pagination'),
          type: 'fraction'
        },
        navigation: hasNavigation ? {
          prevEl: prevArrow,
          nextEl: nextArrow
        } : false,
        on: {
          // Sync active thumbnail with current slide
          slideChange: function() {
            pauseAllNativeVideos();
            const activeIndex = this.activeIndex;
            const section = parentMedia || container.closest('.js-product-images');
            const thumbs = section ? section.querySelectorAll('.js-product-thumb') : [];
            thumbs.forEach(function(thumb, i) {
              thumb.classList.toggle('selected', i === activeIndex);
              thumb.classList.toggle('is-active', i === activeIndex);
            });
          },
          // Reset video state when slide transition ends
          slideChangeTransitionEnd: function() {
            const section = parentMedia || container.closest('.js-product-images');
            if (section) {
              section.querySelectorAll('.js-video').forEach(function(el) {
                el.style.display = '';
              });
              section.querySelectorAll('.js-video-iframe').forEach(function(iframe) {
                iframe.style.display = 'none';
                iframe.innerHTML = '';
              });
            }
          }
        }
      });
    });
    
    // Thumbnail slider
    document.querySelectorAll('.js-product-slider-thumbs').forEach(function(container) {
      if (container.swiper) return;
      
      const parentMedia = container.closest('.js-product-images-thumbs') || container.closest('.js-product-images');
      const settingDirection = container.dataset.direction || 'vertical';
      const direction = window.innerWidth < 768 ? 'horizontal' : settingDirection;
      const gap = 16;

      let perView = 'auto';
      if (direction === 'horizontal' && window.innerWidth >= 768) {
        const slideWidth = 80;
        const available = container.clientWidth;
        perView = Math.floor((available + gap) / (slideWidth + gap));
      }

      createSwiper(container, {
        slidesPerView: perView,
        spaceBetween: gap,
        direction: direction,
        watchOverflow: true,
        navigation: {
          nextEl: parentMedia ? parentMedia.querySelector('.js-product-slider-thumbs-next') : null,
          prevEl: parentMedia ? parentMedia.querySelector('.js-product-slider-thumbs-prev') : null
        }
      });
    });
    
    // The document-level click listener and Fancybox bind below must run
    // exactly once per page load. Swiper branches above guard on
    // `container.swiper`, but these aren't container-scoped — re-running
    // them would accumulate click handlers and Fancybox bindings on every
    // Brand Editor morph.
    if (productGalleryDelegatesBound) return;
    productGalleryDelegatesBound = true;

    // Thumbnail click: navigate main slider and update active state
    document.addEventListener('click', function(e) {
      const thumb = e.target.closest('.js-product-thumb');
      if (!thumb) return;

      e.preventDefault();

      const index = parseInt(thumb.dataset.thumbLoop || thumb.dataset.index, 10);
      const section = thumb.closest('.js-product-images');
      const mainSlider = section ? section.querySelector('.js-product-slider') : null;
      const swiperInstance = mainSlider ? mainSlider.swiper : null;

      if (swiperInstance) {
        swiperInstance.slideTo(index);
      }

      // Native video thumb: open video modal via fancybox trigger
      var videoId = thumb.getAttribute('data-video_id');
      if (videoId && thumb.classList.contains('js-product-thumb-modal')) {
        var trigger = document.getElementById('trigger-video-modal-' + videoId);
        if (trigger) {
          trigger.click();
          return;
        }
      }

      const allThumbs = section ? section.querySelectorAll('.js-product-thumb') : [];
      allThumbs.forEach(function(t) {
        t.classList.remove('is-active');
        t.classList.remove('selected');
      });
      thumb.classList.add('is-active');
      thumb.classList.add('selected');
    });

    // Fancybox lightbox for product gallery
    const FancyboxLib = window.Fancybox;
    if (FancyboxLib) {
      FancyboxLib.bind('[data-fancybox="product-gallery"]', {
        Thumbs: false,
        Toolbar: {
          display: {
            left: [],
            middle: ['infobar'],
            right: ['close'],
          },
        },
        Carousel: {
          Navigation: {
            prevTpl: '<svg><use xlink:href="#arrow-long"/></svg>',
            nextTpl: '<svg><use xlink:href="#arrow-long"/></svg>',
          },
        },
        on: {
          'Carousel.change': function() {
            pauseAllNativeVideos();
          },
          close: function(fancybox) {
            pauseAllNativeVideos();
            const slide = fancybox.getSlide();
            const currentIndex = slide ? slide.index : 0;
            const triggerEl = slide ? slide.triggerEl : null;
            const section = triggerEl ? triggerEl.closest('.js-product-images') : null;
            const swiperEl = section ? section.querySelector('.js-product-slider') : null;
            if (swiperEl && swiperEl.swiper) {
              swiperEl.swiper.slideTo(currentIndex, 0);
            }
            const thumbs = section ? section.querySelectorAll('.js-product-thumb') : [];
            thumbs.forEach(function(t) { t.classList.remove('selected'); });
            const activeThumb = section ? section.querySelector('.js-product-thumb[data-thumb-loop="' + currentIndex + '"]') : null;
            if (activeThumb) {
              activeThumb.classList.add('selected');
            }
          },
        },
      });
    }
  }

  /**
   * Product Video
   * Loads and displays product video in the gallery when available.
   */
  function initProductVideo() {
    document.querySelectorAll('.js-product-video-link').forEach(function(videoLink) {
      const videoUrl = videoLink.getAttribute('data-video-url') || videoLink.getAttribute('href');
      if (videoUrl) {
        LS.loadVideo(videoUrl);
      }
    });
  }

  /**
   * Native Video (Cloudflare Stream)
   * Initializes native video players and handles play/pause interactions.
   */
  var streamVideos = [];

  function pauseAllNativeVideos() {
    streamVideos.forEach(function(player) {
      player.pause();
    });
  }

  function setupNativeVideoPlayers() {
    if (typeof window.Stream !== 'function') return;

    document.querySelectorAll('.js-external-video-iframe-container iframe').forEach(function(iframe) {
      if (!iframe.id) return;
      var player = window.Stream(iframe);
      streamVideos.push(player);
    });

    document.querySelectorAll('.js-play-native-button').forEach(function(btn) {
      btn.addEventListener('click', function() {
        pauseAllNativeVideos();
        var uid = this.getAttribute('data-video_uid');
        if (!uid) return;
        var iframe = document.getElementById('video-' + uid);
        var image = document.querySelector('img[data-video_uid="' + uid + '"]');
        var parent = this.closest('.embed-responsive-16by9');
        var container = document.querySelector('div[data-video_uid="' + uid + '"]');

        if (iframe) {
          iframe.setAttribute('src', iframe.getAttribute('data-src'));
          var allowAttr = iframe.getAttribute('allow');
          if (allowAttr) {
            allowAttr = allowAttr.split(';').map(function(item) { return item.trim(); }).filter(function(item) { return item && item !== 'autoplay'; }).join('; ');
            iframe.setAttribute('allow', allowAttr + ';');
          }
        }
        if (container) container.style.display = '';
        if (image) image.style.display = 'none';
        this.style.display = 'none';
        this.classList.remove('d-md-block');
        if (parent) parent.classList.remove('embed-responsive-16by9');
      });
    });
  }

  function initNativeVideos() {
    var hasNativeVideoElements = document.querySelectorAll('.js-external-video-iframe-container').length > 0;
    if (!hasNativeVideoElements) return;

    if (typeof window.Stream === 'function') {
      setupNativeVideoPlayers();
    } else {
      var script = document.createElement('script');
      script.src = 'https://embed.cloudflarestream.com/embed/sdk.latest.js';
      script.onload = setupNativeVideoPlayers;
      document.head.appendChild(script);
    }
  }

  const noStockVariants = function(container) {
    const config = {
      variantsGroup: '.js-product-variants-group',
      variantButton: '.js-variant-button',
      noStockClass: 'btn-variant-no-stock',
      dataVariationId: 'data-variation-id',
      dataOption: 'data-option'
    };

    let wrapperEl;
    if (container) {
      wrapperEl = container.nodeType ? container : document.querySelector(container);
    } else {
      wrapperEl = document.querySelector('#single-product');
    }
    if (!wrapperEl) return;

    const dataVariantsAttr = wrapperEl.getAttribute('data-variants');
    if (!dataVariantsAttr) return;
    
    let dataVariants;
    try {
      dataVariants = JSON.parse(dataVariantsAttr);
    } catch (e) {
      return;
    }
    
    const variantGroupEls = wrapperEl.querySelectorAll(config.variantsGroup);
    if (!variantGroupEls.length) return;
    
    const variationIds = [];
    for (let idx = 0; idx < variantGroupEls.length; idx++) {
      variationIds.push(variantGroupEls[idx].getAttribute('data-variation-id'));
    }

    const getOptions = function(variationIndex, buttonElement) {
      const options = {};
      for (let i = 0; i <= variationIndex; i++) {
        if (i < variationIndex) {
          const selectSelector = config.variantsGroup + '[' + config.dataVariationId + '="' + variationIds[i] + '"] select';
          const selectEl = wrapperEl.querySelector(selectSelector);
          options['option' + i] = String(selectEl ? selectEl.value : '');
        } else {
          options['option' + i] = String(buttonElement.getAttribute('data-option'));
        }
      }
      return options;
    };

    const filterVariants = function(options) {
      return dataVariants.filter(function(variant) {
        return Object.keys(options).every(function(optionKey) {
          return variant[optionKey] === options[optionKey];
        }) && variant.available;
      });
    };

    const updateStockStatus = function(variationIndex) {
      const variationId = variationIds[variationIndex];
      const variationGroupSelector = config.variantsGroup + '[' + config.dataVariationId + '="' + variationId + '"]';
      const variationGroupEl = wrapperEl.querySelector(variationGroupSelector);
      
      if (!variationGroupEl) return;
      
      const buttons = variationGroupEl.querySelectorAll(config.variantButton);
      
      const noStockButtons = variationGroupEl.querySelectorAll(config.variantButton + '.' + config.noStockClass);
      for (let j = 0; j < noStockButtons.length; j++) {
        noStockButtons[j].classList.remove(config.noStockClass);
      }

      for (let idx = 0; idx < buttons.length; idx++) {
        const buttonEl = buttons[idx];
        const options = getOptions(variationIndex, buttonEl);
        const itemsAvailable = filterVariants(options);
        
        if (!itemsAvailable.length) {
          buttonEl.classList.add(config.noStockClass);
        }
      }
    };

    for (let i = variantGroupEls.length - 1; i >= 0; i--) {
      updateStockStatus(i);
    }
  };

  window.noStockVariants = noStockVariants;

  const changeVariantButton = function(clickedElement, parentSelector) {
    const siblings = clickedElement.parentElement.children;
    for (let i = 0; i < siblings.length; i++) {
      siblings[i].classList.remove('selected');
    }
    clickedElement.classList.add('selected');
    
    const option_id = clickedElement.getAttribute('data-option');
    const variation_id = clickedElement.getAttribute('data-variation-id');
    
    const parentElement = clickedElement.closest(parentSelector);
    if (!parentElement) return;
    
    let selectElement = null;
    
    if (variation_id) {
      const selectId = 'variation_' + (parseInt(variation_id, 10) + 1);
      selectElement = parentElement.querySelector('.js-item-variants select#' + selectId);
      
      if (!selectElement) {
        selectElement = parentElement.querySelector('.js-item-variants select[name="variation[' + variation_id + ']"]');
      }
    }
    
    if (!selectElement) {
      const variantGroup = clickedElement.closest('.js-product-variants-group');
      if (variantGroup) {
        selectElement = variantGroup.querySelector('select.js-variation-option');
      }
    }
    
    if (selectElement && selectElement.options) {
      const options = selectElement.options;
      for (let i = 0; i < options.length; i++) {
        if (options[i].value == option_id) {
          selectElement.selectedIndex = i;
          selectElement.dispatchEvent(new Event('change', { bubbles: true }));
          break;
        }
      }
    }
    
    const labelElement = parentElement.querySelector('.js-insta-variation-label');
    if (labelElement) {
      const nameSpan = clickedElement.querySelector('[data-name]');
      const optionName = nameSpan ? nameSpan.getAttribute('data-name') : clickedElement.getAttribute('title');
      labelElement.textContent = optionName || option_id;
    }
  };
  
  function refreshInstallmentv2(price) {
    document.querySelectorAll('.js-modal-installment-price').forEach(function(el) {
      const installment = Number(el.getAttribute('data-installment'));
      if (installment && LS.currency) {
        el.textContent = LS.currency.display_short + (price / installment).toLocaleString('de-DE', { maximumFractionDigits: 2, minimumFractionDigits: 2 });
      }
    });
  }

  function changeVariant(variant) {
    // Resolve parent container(s) and detect quickshop context
    const parents = [];
    let isQuickshop = false;
    
    if (variant.element) {
      let el = variant.element;
      
      if (typeof el === 'string') {
        el = document.querySelector(el);
      } else if (!el.querySelector && el[0]) {
        el = el[0];
      }
      
      if (el && el.querySelector) {
        if (el.classList.contains('js-quickshop-container') || el.closest('#quickshop-modal')) {
          isQuickshop = true;
          parents.push(el);
          const originalItem = document.querySelector('.js-quickshop-opened');
          if (originalItem) {
            parents.push(originalItem);
          }
        } else {
          parents.push(el);
        }
      }
    }
    
    if (parents.length === 0) {
      parents.push(document.body);
    }
    
    // Reset shipping calculator on PDP variant change
    if (!isQuickshop) {
      document.querySelectorAll('.js-product-detail .js-shipping-calculator-response').forEach(function(el) { el.style.display = 'none'; });
      
      const shippingVariantId = document.querySelector('#shipping-variant-id');
      if (shippingVariantId) shippingVariantId.value = variant.id;
    }
    
    // Scoped query helpers for parent container(s)
    const find = function(selector) {
      const results = [];
      parents.forEach(function(p) {
        const els = p.querySelectorAll(selector);
        for (let i = 0; i < els.length; i++) {
          results.push(els[i]);
        }
      });
      return results;
    };
    const findOne = function(selector) {
      for (let i = 0; i < parents.length; i++) {
        const el = parents[i].querySelector(selector);
        if (el) return el;
      }
      return null;
    };

    // Update SKU and stock text
    const sku = findOne('.js-product-sku');
    if (sku) {
      sku.textContent = variant.sku;
      sku.style.display = '';
    }

    find('.js-product-stock').forEach(function(el) {
      el.textContent = variant.stock;
      el.style.display = '';
    });
    var stockLabel = findOne('.js-stock-available-label');
    if (stockLabel) {
      stockLabel.textContent = variant.stock == 1 ? stockLabel.getAttribute('data-singular') : stockLabel.getAttribute('data-plural');
    }

    // Update installments and payment methods
    const installmentHelper = function(container, amount, price) {
      if (!container) return;
      const amountEl = container.querySelector('.js-installment-amount');
      const priceEl = container.querySelector('.js-installment-price');
      const totalEl = container.querySelector('.js-installment-total-price');
      
      if (amountEl) amountEl.textContent = amount;
      if (priceEl) {
        priceEl.setAttribute('data-value', price);
        priceEl.textContent = LS.currency.display_short + parseFloat(price).toLocaleString('de-DE', { minimumFractionDigits: 2 });
      }
      if (totalEl) {
        if (variant.price_short && Math.abs(variant.price_number - price * amount) < 1) {
          totalEl.textContent = variant.price_short;
        } else {
          totalEl.textContent = LS.currency.display_short + (price * amount).toLocaleString('de-DE', { minimumFractionDigits: 2 });
        }
      }
    };

    const paymentsModule = findOne('.js-product-payments-container');

    if (variant.installments_data) {
      const variantInstallments = JSON.parse(variant.installments_data);
      let maxInstallmentsWithoutInterests = [0, 0];
      let maxInstallmentsWithInterests = [0, 0];

      document.querySelectorAll('.js-payment-provider-installments-row').forEach(function(el) {
        el.style.display = 'none';
      });

      for (const paymentMethod in variantInstallments) {
        const installments = variantInstallments[paymentMethod];
        const methodId = '#installment_' + paymentMethod.replace(/ /g, '_') + '_1';
        const methodContainer = document.querySelector(methodId);
        const minimumInstallmentValue = parseFloat(methodContainer?.closest('.js-info-payment-method')?.getAttribute('data-minimum-installment-value')) || 0;

        for (const numberOfInstallment in installments) {
          const installmentData = installments[numberOfInstallment];
          const installmentContainerSelector = '#installment_' + paymentMethod.replace(/ /g, '_') + '_' + numberOfInstallment;
          const installmentContainer = document.querySelector(installmentContainerSelector);

          const num = parseInt(numberOfInstallment);
          if (installmentData.without_interests && num > maxInstallmentsWithoutInterests[0]) {
            maxInstallmentsWithoutInterests = [num, installmentData.installment_value.toFixed(2)];
          }
          if (!installmentData.without_interests && num > maxInstallmentsWithInterests[0]) {
            maxInstallmentsWithInterests = [num, installmentData.installment_value.toFixed(2)];
          }

          if (installmentContainer && minimumInstallmentValue <= installmentData.installment_value) {
            installmentContainer.style.display = '';
          }

          if (!isQuickshop) {
            installmentHelper(installmentContainer, numberOfInstallment, installmentData.installment_value.toFixed(2));
          }
        }
      }

      const installmentsToUse = maxInstallmentsWithoutInterests[0] > 1 ? maxInstallmentsWithoutInterests : maxInstallmentsWithInterests;
      const installmentsContainer = findOne('.js-max-installments-container .js-max-installments');
      const installmentsModalLink = findOne('#btn-installments');
      const installmentsCardIcon = findOne('.js-installments-credit-card-icon');

      if (installmentsToUse[0] <= 1) {
        [installmentsContainer, installmentsModalLink, paymentsModule, installmentsCardIcon].forEach(function(el) { if (el) el.style.display = 'none'; });
      } else {
        [installmentsContainer, installmentsModalLink, paymentsModule, installmentsCardIcon].forEach(function(el) { if (el) el.style.display = ''; });
        installmentHelper(installmentsContainer, installmentsToUse[0], installmentsToUse[1]);
      }

    }

    if (variant.contact && paymentsModule) {
      paymentsModule.style.display = 'none';
    }

    // Update one-payment display in installments modal
    document.querySelectorAll('#installments-modal .js-installments-one-payment').forEach(function(el) {
      el.textContent = variant.price_short;
      el.setAttribute('data-value', variant.price_number);
    });

    // Update price display
    if (variant.price_short) {
      const variant_price_clean = variant.price_short.replace('$', '').replace('R', '').replace(',', '').replace('.', '');
      const variant_price_raw = parseInt(variant_price_clean, 10);

      find('.js-price-display').forEach(function(el) {
        el.textContent = variant.price_short;
        el.setAttribute('content', variant.price_number);
        el.dataset.productPrice = variant_price_raw;
        el.style.display = '';
      });

      find('.js-price-without-taxes').forEach(function(el) {
        el.textContent = variant.price_without_taxes;
      });
      find('.js-price-without-taxes-container').forEach(function(el) { el.style.display = ''; });
    } else {
      find('.js-price-display').forEach(function(el) { el.style.display = 'none'; });
      find('.js-price-without-taxes-container').forEach(function(el) { el.style.display = 'none'; });
    }

    // Update compare at price and savings
    const priceDisplay = findOne('.js-price-display');
    const priceIsVisible = priceDisplay && getComputedStyle(priceDisplay).display !== 'none';
    
    if (variant.compare_at_price_short && priceIsVisible) {
      find('.js-compare-price-display').forEach(function(el) {
        el.textContent = variant.compare_at_price_short;
        el.style.display = '';
      });

      if (variant.compare_at_price_number > variant.price_number) {
        const saved_compare_price_money = variant.compare_at_price_number - variant.price_number;
        find('.js-offer-saved-money').forEach(function(el) {
          el.textContent = LS.formatToCurrency(saved_compare_price_money);
        });
        find('.js-saved-money-message').forEach(function(el) { el.style.display = ''; });
        
        const discount_percentage = Math.round(((variant.compare_at_price_number - variant.price_number) / variant.compare_at_price_number) * 100);
        const offerPercentage = findOne('.js-offer-percentage');
        if (offerPercentage) {
          offerPercentage.textContent = discount_percentage;
        }
        find('.js-offer-label').forEach(function(el) { el.style.display = ''; });
      } else {
        find('.js-saved-money-message').forEach(function(el) { el.style.display = 'none'; });
        find('.js-offer-label').forEach(function(el) { el.style.display = 'none'; });
      }
    } else {
      find('.js-compare-price-display').forEach(function(el) { el.style.display = 'none'; });
      find('.js-saved-money-message').forEach(function(el) { el.style.display = 'none'; });
      find('.js-offer-label').forEach(function(el) { el.style.display = 'none'; });
    }

    // Update CTA button state and label
    const button = findOne('.js-addtocart');
    const productShippingCalculator = findOne('#product-shipping-container');
    
    if (button) {
      button.classList.remove('cart', 'contact', 'nostock');

      if (!variant.available) {
        button.value = button.getAttribute('data-no-stock-label') || '';
        button.classList.add('nostock');
        button.disabled = true;
        if (productShippingCalculator) productShippingCalculator.style.display = 'none';
      } else if (variant.contact) {
        button.value = button.getAttribute('data-contact-label') || '';
        button.classList.add('contact');
        button.disabled = false;
        if (productShippingCalculator) productShippingCalculator.style.display = 'none';
      } else {
        button.value = button.getAttribute('data-add-to-cart-label') || '';
        button.classList.add('cart');
        button.disabled = false;
        if (productShippingCalculator) productShippingCalculator.style.display = '';
      }
    }

    // Update stock and offer labels for out-of-stock variants
    var stockLabels = find('.js-stock-label-private');
    stockLabels.forEach(function(stockLabel) {
      if (!variant.available) {
        if (!stockLabel.textContent.trim() && stockLabel.getAttribute('data-label')) {
          stockLabel.textContent = stockLabel.getAttribute('data-label');
        }
        stockLabel.style.display = '';
      } else {
        stockLabel.style.display = 'none';
      }
    });
    if (stockLabels.length && !variant.available) {
      find('.js-offer-label').forEach(function(el) { el.style.display = 'none'; });
    }

    // Update installment v2 modal prices
    if (variant.price_number) {
      const priceEl = document.querySelector('#price_display');
      const basePrice = priceEl ? Number(priceEl.getAttribute('content')) : variant.price_number;
      refreshInstallmentv2(basePrice);
    }

    // Update stock warnings (last unit / low stock)
    if (variant.stock == 1) {
      find('.js-last-product').forEach(function(el) { el.style.display = ''; });
    } else {
      find('.js-last-product').forEach(function(el) { el.style.display = 'none'; });
    }

    const latestProductsEl = findOne('.js-latest-products-available');
    if (latestProductsEl) {
      const stock_limit = parseInt(latestProductsEl.getAttribute('data-limit'), 10);
      if (variant.stock < stock_limit && variant.stock != null && variant.stock != 1 && variant.stock != 0) {
        latestProductsEl.style.display = '';
      } else {
        latestProductsEl.style.display = 'none';
      }
    }

    // Refresh shipping calculator state
    LS.updateShippingProduct();

    const shippingInput = document.querySelector('#product-shipping-container .js-shipping-input');
    const currentZip = document.querySelector('#product-shipping-container .js-shipping-calculator-current-zip');
    if (shippingInput && currentZip) {
      currentZip.textContent = shippingInput.value;
    }

    // Update free shipping label visibility based on new variant price
    if (document.querySelector('.js-ship-free-min')) {
      LS.freeShippingProgress(true, parents[0]);
    }

    LS.subscriptionChangeVariant(variant);

    // Navigate gallery to variant image and mark it as active
    if (variant.image) {
      const swiperContainer = findOne('.js-product-slider');
      if (swiperContainer && swiperContainer.swiper) {
        const liImage = swiperContainer.querySelector('[data-image="' + variant.image + '"]');
        if (liImage) {
          // Grid on desktop scrolls to the image; slider (any other case) slides to it.
          const isDesktopGrid = swiperContainer.closest('[data-gallery-format="grid"]')
            && window.matchMedia('(min-width: 768px)').matches;

          if (isDesktopGrid) {
            const target = liImage.querySelector('.js-product-slide-link') || liImage;
            target.scrollIntoView({ behavior: 'smooth', block: 'center' });
          } else {
            const selectedPosition = liImage.getAttribute('data-image-position');
            const slideToGo = parseInt(selectedPosition, 10);
            if (!isNaN(slideToGo)) {
              swiperContainer.swiper.slideTo(slideToGo);
            }
          }
          swiperContainer.querySelectorAll('.js-product-slide-img').forEach(function(img) {
            img.classList.remove('js-active-variant');
          });
          const variantImg = liImage.querySelector('.js-product-slide-img');
          if (variantImg) {
            variantImg.classList.add('js-active-variant');
          }
        }
      }
    }

    // Update variant button stock status
    noStockVariants();
  }
  
  /**
   * Product Variants
   * Registers variant change callbacks to update price, images, stock, and availability.
   */
  function initProductVariants() {
    document.addEventListener('click', function(e) {
      const variant = e.target.closest('.js-variant-button');
      if (!variant) return;
      
      e.preventDefault();
      changeVariantButton(variant, '.js-product-variants-group');
    });
    
    document.addEventListener('click', function(e) {
      const colorVariant = e.target.closest('.js-color-variant');
      if (!colorVariant) return;
      if (window.innerWidth <= 767) return;
      
      e.preventDefault();
      changeVariantButton(colorVariant, '.js-product-item-private');
    });
    
    document.addEventListener('change', function(e) {
      if (!e.target.classList.contains('js-variation-option')) return;
      
      const parent = e.target.closest('.js-product-variants');
      if (!parent) return;
      
      if (parent.classList.contains('js-product-quickshop-variants')) {
        const productItem = e.target.closest('.js-product-item-private');
        const quickshopModal = e.target.closest('#quickshop-modal');
        
        if (quickshopModal) {
          LS.changeVariant(changeVariant, '.js-quickshop-container');
        } else if (productItem) {
          const quickshopId = productItem.getAttribute('data-quickshop-id');
          if (quickshopId) {
            const selector = '.js-product-item-private[data-quickshop-id="' + quickshopId + '"]';
            LS.changeVariant(changeVariant, selector);
          }
        }
      } else {
        LS.changeVariant(changeVariant, '#single-product');
      }
    });
  }

  /**
   * Quantity Selectors
   * Handles plus/minus buttons for quantity inputs on product detail page.
   */
  function initQuantitySelectors() {
    document.addEventListener('click', function(e) {
      const upBtn = e.target.closest('.js-quantity .js-quantity-up');
      const downBtn = e.target.closest('.js-quantity .js-quantity-down');
      const btn = upBtn || downBtn;
      if (!btn) return;

      const quantityContainer = btn.closest('.js-quantity');
      const input = quantityContainer ? quantityContainer.querySelector('.js-quantity-input') : null;
      if (!input) return;

      const currentVal = parseInt(input.value, 10);
      if (upBtn) {
        input.value = currentVal + 1;
      } else if (currentVal > 1) {
        input.value = currentVal - 1;
      }
      input.dispatchEvent(new Event('change', { bubbles: true }));
    });
  }

  /**
   * Add to Cart
   * Handles add to cart button click with AJAX, animations, and modal/notification display.
   */
  function initAddToCart() {

    document.addEventListener('click', function(e) {
      const addToCartBtn = e.target.closest('.js-addtocart:not(.js-addtocart-placeholder)');
      if (!addToCartBtn) return;

      // Skip contact buttons
      if (addToCartBtn.classList.contains('contact')) return;

      // Resolve product container and context
      const productContainer = addToCartBtn.closest('.js-product-container');
      if (!productContainer) return;

      const productVariants = productContainer.querySelectorAll('.js-variation-option');
      const productButton = productContainer.querySelector("input[type='submit'].js-addtocart");
      
      const productButtonWidth = productButton.offsetWidth;
      const productButtonHeight = productButton.offsetHeight;

      const isQuickShop = productContainer.classList.contains('js-product-item-private');
      const isCrossSelling = productContainer.classList.contains('js-cross-selling-container');

      // Button placeholder elements for add-to-cart animation
      const productButtonContainer = productButton.closest('.js-item-submit-container');
      const productButtonPlaceholder = productContainer.querySelector('.js-addtocart-placeholder');
      const productButtonText = productButtonPlaceholder ? productButtonPlaceholder.querySelector('.js-addtocart-text') : null;
      const productButtonAdding = productButtonPlaceholder ? productButtonPlaceholder.querySelector('.js-addtocart-adding') : null;
      const productButtonSuccess = productButtonPlaceholder ? productButtonPlaceholder.querySelector('.js-addtocart-success') : null;

      // Collect product data for notification
      let imageSrc = '';
      const activeVariantImg = productContainer.querySelector('.js-product-slide-img.js-active-variant');
      const defaultImg = productContainer.querySelector('.js-product-slide-img');
      var targetImg = activeVariantImg || defaultImg;

      if (targetImg) {
        var srcsetVal = targetImg.getAttribute('srcset') || targetImg.getAttribute('data-srcset') || '';
        if (srcsetVal) {
          var candidates = srcsetVal.split(',');
          imageSrc = candidates[candidates.length - 1].trim().split(' ')[0];
        }
      }

      const quantityInput = productContainer.querySelector('.js-quantity-input');
      let quantity = quantityInput ? quantityInput.value : 1;
      const nameEl = productContainer.querySelector('.js-product-name');
      let name = nameEl ? nameEl.textContent : '';
      const priceEl = productContainer.querySelector('.js-price-display');
      let price = priceEl ? priceEl.textContent : '';
      
      let addedToCartCopy = productContainer.getAttribute('data-add-to-cart-text');

      // Override product data for cross-selling or quickshop contexts
      if (isCrossSelling) {
        const crossImg = productContainer.querySelector('.js-cross-selling-product-image');
        imageSrc = crossImg ? crossImg.getAttribute('src') : '';
        quantity = productContainer.dataset.quantity;
        const crossName = productContainer.querySelector('.js-cross-selling-product-name');
        name = crossName ? crossName.textContent : '';
        const crossPrice = productContainer.querySelector('.js-cross-selling-promo-price');
        price = crossPrice ? crossPrice.textContent : '';
        addedToCartCopy = productContainer.dataset.addToCartTranslation;
      } else if (isQuickShop) {
        const quickshopImg = productContainer.querySelector('img');
        imageSrc = quickshopImg ? (quickshopImg.getAttribute('srcset') || quickshopImg.getAttribute('src') || '') : '';
        const quickshopQuantityInput = productContainer.querySelector('.js-quantity-input');
        quantity = quickshopQuantityInput ? quickshopQuantityInput.value : 1;
        const itemNameEl = productContainer.querySelector('.js-item-name');
        name = itemNameEl ? itemNameEl.textContent : '';
        const quickshopPriceEl = productContainer.querySelector('.js-price-display');
        price = quickshopPriceEl ? quickshopPriceEl.textContent.trim() : '';
        if (productContainer.classList.contains('js-quickshop-has-variants')) {
          addedToCartCopy = productContainer.getAttribute('data-add-to-cart-label') || '';
        } else {
          addedToCartCopy = productContainer.getAttribute('data-buy-label') || '';
        }
      }

      const isAjaxCart = document.body.dataset.ajaxCart === 'true';

      if (isAjaxCart) {
        e.preventDefault();
      }

      // Show adding animation: hide real button, show placeholder with spinner
      if (productButton && productButton.style) {
        productButton.style.display = 'none';
      }
      if (isQuickShop && productButtonContainer) {
        productButtonContainer.style.display = 'none';
      }

      if (productButtonPlaceholder) {
        productButtonPlaceholder.style.width = (productButtonWidth + 20) + 'px';
        productButtonPlaceholder.style.height = productButtonHeight + 'px';
        productButtonPlaceholder.style.display = 'block';
      }
      fadeOut(productButtonText);
      if (productButtonAdding) {
        productButtonAdding.classList.add('active');
      }

      // Restore button to its initial state
      function restoreButtonInitialState() {
        if (productButtonAdding) {
          productButtonAdding.classList.remove('active');
        }
        fadeIn(productButtonText);
        if (productButtonPlaceholder) {
          productButtonPlaceholder.removeAttribute('style');
          productButtonPlaceholder.style.display = 'none';
        }
        if (productButton && productButton.style) {
          productButton.style.display = '';
        }
        if (isQuickShop && productButtonContainer) {
          productButtonContainer.style.display = '';
        }
      }

      // Subscription validation
      const subscriptionCallbackError = function() {
        setTimeout(function() {
          restoreButtonInitialState();
        }, 500);
      };

      LS.subscriptionSubmit(jQueryNuvem(productContainer), subscriptionCallbackError, e);

      if (isAjaxCart) {

        // AJAX add to cart success callback
        const callbackAddToCart = function(htmlNotificationRelatedProducts, htmlNotificationCrossSelling) {

          // Update notification with product data (querySelectorAll because both toast and modal have these elements)
          document.querySelectorAll('.js-cart-notification-item-image-private').forEach(function(img) {
            img.setAttribute('srcset', imageSrc);
            img.setAttribute('src', imageSrc);
          });
          document.querySelectorAll('.js-cart-notification-item-name-private').forEach(function(el) { el.textContent = name; });
          document.querySelectorAll('.js-cart-notification-item-quantity-private').forEach(function(el) { el.textContent = quantity; });
          document.querySelectorAll('.js-cart-notification-item-price-private').forEach(function(el) { el.textContent = price; });

          LS.updateNotificationDiscountLabel(productContainer);

          // Show selected variant options in notification
          var variantText = productVariants.length > 0 ? Array.from(productVariants).map(function(v) { return v.value; }).join(', ') : '';
          document.querySelectorAll('.js-cart-notification-item-variant-container-private').forEach(function(el) {
            el.style.display = productVariants.length > 0 ? '' : 'none';
          });
          if (productVariants.length > 0) {
            document.querySelectorAll('.js-cart-notification-item-variant-private').forEach(function(el) { el.textContent = variantText; });
          }

          // Update cart badge count
          const cartItemsBadge = document.querySelector('.js-cart-widget-amount');
          const cartItemsMoney = document.querySelector('.js-cart-widget-total');
          const cartItemsAmount = cartItemsBadge ? parseInt(cartItemsBadge.textContent, 10) : 0;

          if (cartItemsBadge) cartItemsBadge.style.display = cartItemsAmount === 0 ? 'none' : '';

          if (cartItemsBadge && window.innerWidth > 768 && cartItemsMoney) {
            cartItemsMoney.classList.remove('d-none', 'd-md-inline-block');
          }

          // Toggle singular/plural cart counts
          document.querySelectorAll('.js-cart-counts-plural-private').forEach(function(el) {
            el.style.display = cartItemsAmount > 1 ? '' : 'none';
          });
          document.querySelectorAll('.js-cart-counts-singular-private').forEach(function(el) {
            el.style.display = cartItemsAmount > 1 ? 'none' : '';
          });

          // Show related products notification modal
          const notificationWithRelatedProducts = htmlNotificationRelatedProducts != null;

          if (notificationWithRelatedProducts) {
            const relatedContainer = document.querySelector('.js-related-products-notification-container');
            if (relatedContainer) {
              relatedContainer.innerHTML = '';
              
              if (isQuickShop) {
                const quickshopCloseBtn = document.querySelector('#quickshop-modal .js-modal-close-private');
                if (quickshopCloseBtn) quickshopCloseBtn.click();
                setTimeout(function() {
                  modalHandler.modalOpen('#related-products-notification');
                  relatedContainer.innerHTML = htmlNotificationRelatedProducts;
                  relatedContainer.style.display = '';
                  setTimeout(initRelatedProductsSwiper, 200);
                }, 350);
              } else {
                modalHandler.modalOpen('#related-products-notification');
                relatedContainer.innerHTML = htmlNotificationRelatedProducts;
                relatedContainer.style.display = '';
                setTimeout(initRelatedProductsSwiper, 200);
              }
            }
          }

          // Show cart modal or toast notification
          const shouldShowCrossSellingModal = htmlNotificationCrossSelling != null;

          if (!notificationWithRelatedProducts) {
            if (isQuickShop) {
              const qsClose = document.querySelector('#quickshop-modal .js-modal-close-private');
              if (qsClose) qsClose.click();
            }
            
            const modalCart = document.getElementById('modal-cart');
            const cartOpenType = modalCart ? modalCart.getAttribute('data-cart-open-type') : null;
    
            if (cartOpenType === 'show_cart' && !shouldShowCrossSellingModal) {
              setTimeout(function() {
                modalHandler.modalOpen('#modal-cart');
              }, isQuickShop ? 350 : 0);
            } else {
              setTimeout(function() {
                const alertAddToCart = document.querySelector('.js-alert-add-to-cart-private');
                if (alertAddToCart) {
                  updateNotificationPosition();
                  alertAddToCart.style.display = 'block';
                  requestAnimationFrame(function() {
                    requestAnimationFrame(function() {
                      alertAddToCart.classList.add('notification-visible');
                      alertAddToCart.classList.remove('notification-hidden');
                    });
                  });
                }
              }, 500);

              // Auto-hide notification after 8s (skip on first add)
              if (!cookieService.get('first_product_added_successfully')) {
                cookieService.set('first_product_added_successfully', 1, 7);
              } else {
                setTimeout(function() {
                  const alertAddToCart = document.querySelector('.js-alert-add-to-cart-private');
                  if (alertAddToCart) {
                    alertAddToCart.classList.remove('notification-visible');
                    alertAddToCart.classList.add('notification-hidden');
                    setTimeout(function() {
                      const notificationImage = document.querySelector('.js-cart-notification-item-image-private');
                      if (notificationImage) {
                        notificationImage.setAttribute('src', '');
                      }
                      if (alertAddToCart) {
                        alertAddToCart.style.display = 'none';
                      }
                    }, 500);
                  }
                }, 8000);
              }
            }
          }

          // Show cross-selling modal
          if (htmlNotificationCrossSelling != null) {
            const crossSellingBody = document.querySelector('.js-cross-selling-modal-body');
            if (crossSellingBody) {
              crossSellingBody.innerHTML = '';
              modalHandler.modalOpen('#js-cross-selling-modal');
              crossSellingBody.innerHTML = htmlNotificationCrossSelling;
              crossSellingBody.style.display = '';
            }
            
            const crossSellingContainer = document.querySelector('#js-cross-selling-modal .js-cross-selling-container');
            if (crossSellingContainer) {
              LS.fillCrossSelling(crossSellingContainer);
            }
          }

          // Button success animation sequence
          if (productButtonAdding) {
            productButtonAdding.classList.remove('active');
          }
          if (productButtonSuccess) {
            productButtonSuccess.classList.add('active');
          }
          
          setTimeout(function() {
            if (productButtonSuccess) {
              productButtonSuccess.classList.remove('active');
            }
            fadeIn(productButtonText);
          }, 2000);
          
          setTimeout(function() {
            if (productButtonPlaceholder) {
              productButtonPlaceholder.removeAttribute('style');
              productButtonPlaceholder.style.display = 'none';
            }
            if (productButton && productButton.style) {
              productButton.style.display = '';
            }
            if (isQuickShop && productButtonContainer) {
              productButtonContainer.style.display = '';
            }
          }, 3000);

          const addedMessage = productContainer.querySelector('.js-added-to-cart-product-message');
          if (addedMessage) {
            addedMessage.style.display = '';
          }

          // Close quickshop modal after adding to cart
          if (isQuickShop) {
            const qsModal = document.querySelector('#quickshop-modal');
            if (qsModal) qsModal.classList.remove('modal-visible');
            const qsOverlay = document.querySelector(".js-modal-overlay-private[data-target='#quickshop-modal']");
            if (qsOverlay) qsOverlay.style.display = 'none';
            document.body.classList.remove('modal-open');
            restoreQuickshopForm();
          }

          if (isCrossSelling) {
            const crossSellingCloseBtn = document.querySelector('#js-cross-selling-modal .js-modal-close-private');
            if (crossSellingCloseBtn) {
              crossSellingCloseBtn.click();
            }
          }
        };

        const callbackError = function() {
          restoreButtonInitialState();
        };

        const addingText = addToCartBtn.getAttribute('data-adding-text');
        const noStockText = addToCartBtn.getAttribute('data-no-stock-text');
        const editableAjaxCart = addToCartBtn.getAttribute('data-editable-ajax-cart') === 'true';

        const form = addToCartBtn.closest('form');
        if (form) {
          LS.addToCartEnhanced(
            form,
            addedToCartCopy,
            addingText,
            noStockText,
            editableAjaxCart,
            callbackAddToCart,
            callbackError
          );
        }
      }
    });
  }

  /**
   * Contact Redirect
   * Redirects to contact page when product has no price (contact/catalog type).
   */
  function initContactRedirect() {
    document.querySelectorAll('.js-product-form').forEach(function(form) {
      form.addEventListener('submit', function(e) {
        const button = form.querySelector('[type="submit"]');
        if (!button) return;
        
        if (button.classList.contains('contact') || button.classList.contains('catalog')) {
          e.preventDefault();
          button.disabled = true;
          const contactUrl = form.getAttribute('data-contact-url');
          if (!contactUrl) return;
          const productId = form.querySelector('input[name="add_to_cart"]');
          window.location = productId ? contactUrl + '?product=' + productId.value : contactUrl;
        }
      });
    });
  }

  /**
   * Related Products Swiper
   * Initializes carousel for related products shown in add-to-cart notification.
   */
  function initRelatedProductsSwiper() {
    const container = document.querySelector('.js-related-products-notification-slider');
    if (!container || container.swiper) return;

    const relatedSection = container.closest('.js-related-products-notification');

    // Get products amount from related section data attribute
    const productsAmount = relatedSection ? parseInt(relatedSection.getAttribute('data-related-amount'), 10) : 0;
    const loopVal = (window.innerWidth < 768 && productsAmount > 3) || (window.innerWidth >= 768 && productsAmount > 4);

    // Create swiper for related products notification slider
    createSwiper(container, {
      lazy: true,
      loop: loopVal,
      watchOverflow: true,
      threshold: 5,
      spaceBetween: 15,
      slidesPerView: 3,
      slidesPerGroup: 3,
      navigation: {
        nextEl: relatedSection ? relatedSection.querySelector('.js-related-products-notification-slider-next') : null,
        prevEl: relatedSection ? relatedSection.querySelector('.js-related-products-notification-slider-prev') : null,
      },
      pagination: {
        el: relatedSection ? relatedSection.querySelector('.js-related-products-notification-slider-pagination') : null,
        clickable: true,
      },
      breakpoints: {
        768: {
          slidesPerView: 4,
          slidesPerGroup: 4,
        }
      }
    });
  }

  /**
   * Product Description Toggle
   * Shows "view more/less" toggle when product description overflows its container.
   */
  function initProductDescriptionToggle() {
    const description = document.querySelector('.js-product-description');
    const toggleContainer = document.querySelector('.js-view-description');
    
    if (!description || !toggleContainer) return;
    
    if (description.offsetHeight < description.scrollHeight) {
      toggleContainer.style.display = 'block';
    }
    
    toggleContainer.addEventListener('click', function(e) {
      e.preventDefault();
      description.classList.toggle('product-description-full');
      const viewMore = toggleContainer.querySelector('.js-view-more');
      const viewLess = toggleContainer.querySelector('.js-view-less');
      if (viewMore && viewLess) {
        const isExpanded = description.classList.contains('product-description-full');
        viewMore.style.display = isExpanded ? 'none' : 'inline';
        viewLess.style.display = isExpanded ? 'inline' : 'none';
      }
    });
  }

  /**
   * Product Recommendations
   * Initializes carousels for related, alternative, and complementary product sections.
   */
  function initProductRecommendations() {
    const productSections = document.querySelectorAll('.js-product-recommendations');
    
    productSections.forEach(function(section) {
      const swiperContainer = section.querySelector('.js-recommendations-swiper');
      if (!swiperContainer || swiperContainer.swiper) return;
      
      const sliderWrapper = section.closest('[data-columns-desktop]') || section.closest('.js-products-slider-section');

      let slidesPerViewDesktop = 5;
      let slidesPerViewMobile = 2;
      
      if (sliderWrapper) {
        const dataDesktop = sliderWrapper.getAttribute('data-columns-desktop');
        const dataMobile = sliderWrapper.getAttribute('data-columns-mobile');
        if (dataDesktop) slidesPerViewDesktop = parseInt(dataDesktop, 10) || 5;
        if (dataMobile) slidesPerViewMobile = parseInt(dataMobile, 10) || 2;
      }
      
      const paginationEl = section.querySelector('.swiper-pagination');
      const prevEl = section.querySelector('.swiper-button-prev');
      const nextEl = section.querySelector('.swiper-button-next');
      
      const slides = swiperContainer.querySelectorAll('.swiper-slide');
      const needsLoop = slides.length > slidesPerViewDesktop;
      
      createSwiper(swiperContainer, {
        lazy: true,
        loop: needsLoop,
        watchOverflow: true,
        threshold: 5,
        watchSlidesVisibility: true,
        slideVisibleClass: 'js-swiper-slide-visible',
        slidesPerView: slidesPerViewMobile,
        spaceBetween: 16,
        navigation: {
          nextEl: nextEl,
          prevEl: prevEl,
        },
        pagination: paginationEl ? {
          el: paginationEl,
          clickable: true,
        } : false,
        breakpoints: {
          768: {
            slidesPerView: slidesPerViewDesktop,
          }
        }
      });
    });
  }

  /**
   * Shipping Calculator
   * Handles zipcode input, calculation triggers, and displays shipping options.
   */
  function initShippingCalculator() {

    // ServicesUrlsProvider falls back to #cart-shipping-container which doesn't exist on PDP without ajax_cart
    const shippingContainer = document.querySelector('#product-shipping-container');
    if (shippingContainer) {
      window.urls = window.urls || {};
      window.urls.shippingUrl = window.urls.shippingUrl || shippingContainer.dataset.shippingUrl;
    }

    // Restore saved zipcode from cookie and auto-calculate shipping on page load
    const zipcodeCookie = cookieService.get('calculator_zipcode');
    if (zipcodeCookie) {
      const productShippingInput = document.querySelector('#product-shipping-container .js-shipping-input');
      if (productShippingInput) {
        productShippingInput.value = zipcodeCookie;
      }
      
      const currentZipEls = document.querySelectorAll('.js-shipping-calculator-current-zip');
      currentZipEls.forEach(function(el) {
        el.textContent = zipcodeCookie;
      });
      
      const productHead = document.querySelector('#product-shipping-container .js-shipping-calculator-head');
      if (productHead && !productHead.classList.contains('js-cart-saved-zipcode')) {
        productHead.classList.add('with-zip');
        productHead.classList.remove('with-form');
        const withZipEl = productHead.querySelector('.js-shipping-calculator-with-zipcode');
        if (withZipEl) {
          withZipEl.classList.add('transition-up-active');
        }
        
        const spinnerEl = productHead.querySelector('.js-shipping-calculator-spinner');
        if (spinnerEl) {
          spinnerEl.style.display = '';
        }
        
        const productShippingContainer = document.querySelector('#product-shipping-container');
        const url = productShippingContainer ? productShippingContainer.getAttribute('data-shipping-url') : null;
        if (url && typeof LS.calculateShippingAjax === 'function') {
          const shippingContainer = productShippingContainer.closest('.js-shipping-calculator-container');
          setTimeout(function() {
            LS.calculateShippingAjax(zipcodeCookie, url, shippingContainer);
          }, 100);
        }
      }
    }
    
    // Restore previously selected shipping cost display
    const selectedShippingMethod = document.querySelector('.js-selected-shipping-method');
    if (selectedShippingMethod) {
      const shippingCost = selectedShippingMethod.getAttribute('data-cost');
      const shippingCostEl = document.querySelector('#shipping-cost');
      if (shippingCostEl && shippingCost) {
        shippingCostEl.textContent = shippingCost;
        shippingCostEl.classList.remove('opacity-40');
      }
    }
    
    // Calculate shipping button click
    document.addEventListener('click', function(e) {
      const calcBtn = e.target.closest('.js-calculate-shipping');
      if (!calcBtn) return;
      
      e.preventDefault();
      
      const container = calcBtn.closest('[data-store="shipping-calculator"]');
      if (!container) return;
      
      const input = container.querySelector('.js-shipping-input');
      const zipcode = input ? input.value.trim() : '';
      
      if (!zipcode) {
        input?.focus();
        return;
      }
      
      const calcWording = calcBtn.querySelector('.js-calculate-shipping-wording');
      const calcingWording = calcBtn.querySelector('.js-calculating-shipping-wording');
      const spinner = calcBtn.querySelector('.loading');
      
      if (calcWording) calcWording.style.display = 'none';
      if (calcingWording) calcingWording.style.display = '';
      if (spinner) spinner.style.display = '';
      
      calculateShipping(container, zipcode);
    });
    
    // Submit shipping calculation on Enter key
    document.addEventListener('keypress', function(e) {
      if (e.key !== 'Enter') return;
      
      const input = e.target.closest('.js-shipping-input');
      if (!input) return;
      
      e.preventDefault();
      
      const container = input.closest('[data-store="shipping-calculator"]');
      const calcBtn = container?.querySelector('.js-calculate-shipping');
      calcBtn?.click();
    });
    
    // Change zipcode: hide results and show form again
    document.addEventListener('click', function(e) {
      const changeBtn = e.target.closest('.js-shipping-calculator-change-zipcode');
      if (!changeBtn) return;
      
      e.preventDefault();
      
      const container = changeBtn.closest('[data-store="shipping-calculator"]');
      if (!container) return;
      
      const head = container.querySelector('.js-shipping-calculator-head');
      const withZip = container.querySelector('.js-shipping-calculator-with-zipcode');
      const response = container.querySelector('.js-shipping-calculator-response');
      const form = container.querySelector('.js-shipping-calculator-form');
      
      if (response) response.style.display = 'none';
      if (head) head.classList.remove('with-zip');
      if (head) head.classList.add('with-form');
      if (withZip) withZip.classList.remove('transition-up-active');
      if (form) form.classList.add('transition-up-active');
      
      const input = container.querySelector('.js-shipping-input');
      input?.focus();
    });
    
    // Toggle extra shipping/pickup options visibility
    document.addEventListener('click', function(e) {
      const toggleBtn = e.target.closest('.js-toggle-more-shipping-options');
      if (!toggleBtn) return;
      
      e.preventDefault();
      
      const isShipping = toggleBtn.classList.contains('js-show-more-shipping-options');
      const targetClass = isShipping ? '.js-other-shipping-options' : '.js-other-pickup-options';
      const container = toggleBtn.closest('.radio-button-container') || toggleBtn.parentElement;
      const target = container.querySelector(targetClass);
      
      if (target) {
        const isHidden = target.style.display === 'none';
        target.style.display = isHidden ? '' : 'none';
        
        const seeMore = toggleBtn.querySelector('.js-shipping-see-more');
        const seeLess = toggleBtn.querySelector('.js-shipping-see-less');
        if (seeMore) seeMore.style.display = isHidden ? 'none' : '';
        if (seeLess) seeLess.style.display = isHidden ? '' : 'none';
      }
    });
    
    // Select first shipping option on results (native CustomEvent from platform)
    document.addEventListener('shipping.options.checked', function(e) {
      const shippingMethod = e.target.closest('.js-shipping-method');
      if (!shippingMethod) return;
      
      const shippingPrice = shippingMethod.getAttribute('data-price');
      // addToTotal updates the cart total and the mini-cart (cart widget) total.
      if (typeof LS.addToTotal === 'function') {
        LS.addToTotal(shippingPrice);
      }

      selectShippingOption(shippingMethod, false);
    });
    
    // Shipping method change: save selection and hide unavailable alert
    document.addEventListener('change', function(e) {
      const method = e.target.closest('.js-shipping-method, .js-branch-method');
      if (!method) return;

      selectShippingOption(method, true);
      document.querySelectorAll('.js-shipping-method-unavailable').forEach(function(el) {
        el.style.display = 'none';
      });
    });

    // Change shipping country from invalid zipcode modal
    document.addEventListener('click', function(e) {
      const saveBtn = e.target.closest('.js-save-shipping-country');
      if (!saveBtn) return;

      e.preventDefault();

      const modal = saveBtn.closest('.js-modal-shipping-country');
      if (!modal) return;

      const selected = modal.querySelector('.js-country-select option:checked');
      const url = selected ? selected.getAttribute('data-country-url') : null;
      if (url) {
        window.location.href = url;
      }
    });
  }
  
  // Sync zipcode across inputs and trigger LS.calculateShippingAjax for cart or product
  function calculateShipping(container, zipcode) {
    const shippingContainer = container.closest('#product-shipping-container') || container.closest('#cart-shipping-container');
    const url = shippingContainer ? shippingContainer.getAttribute('data-shipping-url') : null;
    if (!url) return;
    
    const currentZipEls = document.querySelectorAll('.js-shipping-calculator-current-zip');
    currentZipEls.forEach(function(el) {
      el.textContent = zipcode;
    });
    
    const allInputs = document.querySelectorAll('.js-shipping-input');
    allInputs.forEach(function(input) {
      input.value = zipcode;
    });
    
    // Only recalculate the cart widget when the click actually came from it
    const cartShippingEl = container.closest('#cart-shipping-container');
    if (cartShippingEl) {
      const cartInput = cartShippingEl.querySelector('.js-shipping-input');
      LS.calculateShippingAjax(
        cartInput ? cartInput.value : '',
        url,
        cartShippingEl.closest('.js-shipping-calculator-container')
      );
    }

    const productContainer = container.closest('#product-shipping-container');
    if (productContainer) {
      LS.calculateShippingAjax(
        zipcode,
        url,
        productContainer.closest('.js-shipping-calculator-container')
      );
    }
  }

  /* ========================================
   * SHOPPING EXPERIENCE - CART
   * ======================================== */

  /**
   * Cart Favicon
   * Swap the favicon for a custom one when the cart has items.
   * URL comes from the settings.cart_favicon image_picker, resolved
   * server-side and exposed on body[data-cart-favicon]. The .js-favicon
   * links are emitted by the platform's head_content (two links: icon +
   * shortcut icon), so both get swapped together.
   */
  function initCartFavicon() {
    const cartFaviconUrl = document.body.dataset.cartFavicon;
    if (!cartFaviconUrl) return;

    // Platform only emits .js-favicon when the store has a base favicon set
    // in Admin. Fall back to an empty <link> so the swap still works.
    let faviconLinks = document.querySelectorAll('.js-favicon');
    if (!faviconLinks.length) {
      const link = document.createElement('link');
      link.rel = 'icon';
      link.className = 'js-favicon';
      link.href = '';
      document.head.appendChild(link);
      faviconLinks = [link];
    }

    const originalHrefs = Array.from(faviconLinks).map((l) => l.getAttribute('href'));

    function applyFavicon(useCart) {
      faviconLinks.forEach(function(link, i) {
        link.setAttribute('href', useCart ? cartFaviconUrl : originalHrefs[i]);
      });
    }

    function cartHasItems() {
      return document.querySelectorAll('.js-cart-item').length > 0;
    }

    if (cartHasItems()) applyFavicon(true);

    document.addEventListener('cart.updated', function() {
      // Wait for the cart DOM to settle after the update before reading items.
      setTimeout(function() { applyFavicon(cartHasItems()); }, 900);
    });
  }

  /**
   * Cart Item Actions
   * Handles quantity changes, item removal, cart modal open, and cart form submit via event delegation.
   */
  function initCartItemActions() {
    document.addEventListener('click', function(e) {
      // Open cart modal from add-to-cart recommendations notification
      if (e.target.closest('.js-open-cart-modal')) {
        modalHandler.modalOpen('#modal-cart');
        return;
      }

      const cartItem = e.target.closest('.js-cart-item');
      if (!cartItem) return;

      const itemId = parseInt(cartItem.dataset.itemId, 10);
      const isAjaxCart = cartItem.hasAttribute('data-cart-ajax') || undefined;

      if (e.target.closest('.js-cart-item-remove')) {
        e.preventDefault();
        LS.removeItem(itemId, isAjaxCart);
      } else if (e.target.closest('.js-cart-quantity-minus') && !e.target.closest('.js-quantity.form-control-disabled')) {
        LS.minusQuantity(itemId, isAjaxCart);
      } else if (e.target.closest('.js-cart-quantity-plus') && !e.target.closest('.js-quantity.form-control-disabled')) {
        LS.plusQuantity(itemId, isAjaxCart);
      }
    });

    document.addEventListener('keypress', function(e) {
      if (!e.target.matches('.js-cart-quantity-input')) return;
      if (e.which != 8 && e.which != 0 && e.which != 44 && e.which != 46 && (e.which < 48 || e.which > 57)) {
        e.preventDefault();
      }
    });

    document.addEventListener('focusout', function(e) {
      if (!e.target.matches('.js-cart-quantity-input')) return;
      var itemID = e.target.getAttribute('data-item-id');
      var itemVAL = e.target.value;
      if (itemVAL === '0') {
        var confirmText = e.target.closest('.js-cart-item').getAttribute('data-confirm-remove');
        if (confirm(confirmText)) {
          LS.removeItem(itemID, true);
        } else {
          e.target.value = 1;
        }
      } else if (itemVAL !== '') {
        LS.changeQuantity(itemID, itemVAL, true);
      }
    });

    // Clear first-add notification cookie on cart form submit (checkout)
    const cartForm = document.querySelector('[data-store="cart-form"]');
    if (cartForm) {
      cartForm.addEventListener('submit', function() {
        cookieService.remove('first_product_added_successfully');
      });
    }
  }

  /**
   * Free Shipping Progress
   * Triggers platform's free shipping progress bar calculation.
   */
  function initFreeShippingProgress() {
    if (document.querySelector('.js-ship-free-min')) {
      LS.freeShippingProgress(true);
    }
  }

  /**
   * Cart Shipping on Load
   * Automatically calculates shipping for cart when a zipcode is saved (cookie or backend).
   */
  function calculateCartShippingOnLoad() {
    const cartShippingInput = document.querySelector('#cart-shipping-container .js-shipping-input');
    const cartShippingContainer = document.querySelector('#cart-shipping-container');
    
    if (!cartShippingContainer) return;
    
    // Restore zipcode from input or cookie fallback, and update cart calculator UI
    let zipcode = cartShippingInput ? cartShippingInput.value.trim() : '';
    
    if (!zipcode) {
      const zipcodeCookie = cookieService.get('calculator_zipcode');
      if (zipcodeCookie) {
        zipcode = zipcodeCookie;
        if (cartShippingInput) {
          cartShippingInput.value = zipcode;
        }
        
        const currentZipEls = document.querySelectorAll('#cart-shipping-container .js-shipping-calculator-current-zip');
        currentZipEls.forEach(function(el) {
          el.textContent = zipcode;
        });
        
        const cartHead = cartShippingContainer.querySelector('.js-shipping-calculator-head');
        if (cartHead) {
          cartHead.classList.add('with-zip');
          cartHead.classList.remove('with-form');
          const withZipEl = cartHead.querySelector('.js-shipping-calculator-with-zipcode');
          if (withZipEl) {
            withZipEl.classList.add('transition-up-active');
          }
        }
      }
    }
    
    // Auto-calculate cart shipping if zipcode is available and cart has items
    const hasCartItems = document.querySelectorAll('.js-cart-item').length > 0;
    
    if (zipcode && hasCartItems && typeof LS.calculateShippingAjax === 'function') {
      const url = cartShippingContainer.getAttribute('data-shipping-url');
      const shippingContainer = cartShippingContainer.closest('.js-shipping-calculator-container');
      
      const spinnerEl = cartShippingContainer.querySelector('.js-shipping-calculator-spinner');
      if (spinnerEl) {
        spinnerEl.style.display = '';
      }
      
      setTimeout(function() {
        LS.calculateShippingAjax(zipcode, url, shippingContainer);
      }, 100);
    }
    
    // Expand branches accordion if a branch method was previously selected
    const branchMethodSelected = document.querySelector('.js-branch-method.js-selected-shipping-method');
    if (branchMethodSelected) {
      const toggleBranches = document.querySelector('#cart-shipping-container .js-toggle-branches');
      if (toggleBranches && typeof window.toggleAccordionPrivate === 'function') {
        window.toggleAccordionPrivate(toggleBranches);
      }
    }
  }

  // Mark selected shipping/pickup option, update cost display, and persist selection
  function selectShippingOption(elem, saveOption) {
    document.querySelectorAll('.js-shipping-method, .js-branch-method').forEach(function(el) {
      el.classList.remove('js-selected-shipping-method');
    });
    elem.classList.add('js-selected-shipping-method');
    
    document.querySelectorAll('.js-shipping-radio').forEach(function(el) {
      el.classList.remove('selected');
    });
    const closestRadio = elem.closest('.js-shipping-radio');
    if (closestRadio) closestRadio.classList.add('selected');
    
    LS.ShippingDiscountRow.apply(elem);

    if (saveOption && typeof LS.saveCalculatedShipping === 'function') {
      LS.saveCalculatedShipping(true);
    }
    
    if (elem.classList.contains('js-shipping-method-hidden')) {
      if (elem.classList.contains('js-pickup-option')) {
        document.querySelectorAll('.js-other-pickup-options, .js-show-other-pickup-options .js-shipping-see-less').forEach(function(el) {
          el.style.display = '';
        });
        document.querySelectorAll('.js-show-other-pickup-options .js-shipping-see-more').forEach(function(el) {
          el.style.display = 'none';
        });
      } else {
        document.querySelectorAll('.js-other-shipping-options, .js-show-more-shipping-options .js-shipping-see-less').forEach(function(el) {
          el.style.display = '';
        });
        document.querySelectorAll('.js-show-more-shipping-options .js-shipping-see-more').forEach(function(el) {
          el.style.display = 'none';
        });
      }
    }
  }

  /**
   * Positions the add-to-cart notification below the cart icon on desktop.
   */
  function updateNotificationPosition() {
    const notification = document.querySelector('.js-notification-cart');
    if (!notification || window.innerWidth < 768) {
      return;
    }
    
    const cartIcon = document.querySelector('.js-cart-container');
    if (!cartIcon) return;
    
    const cartRect = cartIcon.getBoundingClientRect();
    const top = cartRect.bottom + 8;
    let right = window.innerWidth - cartRect.right;
    
    if (right < 16) right = 16;
    
    notification.style.top = top + 'px';
    notification.style.right = right + 'px';
  }

  /**
   * Recalculates notification position when the sticky header changes state
   * (e.g. sticky ↔ static), using MutationObserver and transitionend.
   */
  function initNotificationObserver() {
    const stickyWrapper = document.querySelector('.sticky-header-wrapper');
    if (!stickyWrapper) return;
    
    const observer = new MutationObserver(function() {
      const notification = document.querySelector('.js-notification-cart');
      if (notification && notification.classList.contains('notification-visible')) {
        updateNotificationPosition();
      }
    });
    
    observer.observe(stickyWrapper, { attributes: true, attributeFilter: ['class'] });
    
    stickyWrapper.addEventListener('transitionend', function() {
      const notification = document.querySelector('.js-notification-cart');
      if (notification && notification.classList.contains('notification-visible')) {
        updateNotificationPosition();
      }
    });
  }

  /**
   * Recalculates notification position on scroll when the header crosses
   * the sticky threshold (top ↔ scrolled).
   */
  function initNotificationScrollListener() {
    let notifWasAtTop = window.scrollY <= 10;
    window.addEventListener('scroll', function() {
      const notification = document.querySelector('.js-notification-cart');
      if (!notification || !notification.classList.contains('notification-visible')) return;
      
      const isAtTop = window.scrollY <= 10;
      if (isAtTop !== notifWasAtTop) {
        updateNotificationPosition();
        notifWasAtTop = isAtTop;
      }
    }, { passive: true });
  }

  /* ========================================
   * PREVIEW LIFECYCLE (Brand Editor)
   *
   * When the theme runs inside the Brand Editor preview iframe, the
   * editor sends `brand-editor:select-element` after the merchant picks
   * a block in the sidebar. If the block lives inside a Swiper carousel,
   * the theme drives the Swiper to that slide. Source-filtered to the
   * embedding parent window so third-party scripts on the page can't
   * trigger navigation.
   * ========================================
   */

  /**
   * Drives the Swiper hosting `element` to that slide. Resolves loop
   * duplicates via data-block-id and rebuilds loop clones if they've
   * been stripped by a morph so slideToLoop lands correctly.
   * @param {HTMLElement} container - The `.swiper-container` ancestor.
   * @param {HTMLElement} element - The selected block element (slide or clone).
   */
  function driveSwiperToSlideForSelection(container, element) {
    var swiper = container.swiper;
    if (!swiper) return;

    var originals = Array.from(
      container.querySelectorAll('.swiper-slide:not(.swiper-slide-duplicate)')
    );
    var blockId = element.getAttribute('data-block-id');
    var original = null;
    if (blockId) {
      for (var i = 0; i < originals.length; i++) {
        if (originals[i].getAttribute('data-block-id') === blockId) {
          original = originals[i];
          break;
        }
      }
    }
    if (!original && originals.indexOf(element) !== -1) {
      original = element;
    }
    if (!original) return;

    var realIndex = originals.indexOf(original);
    if (realIndex < 0) return;

    // Stop autoplay so it doesn't drift past the merchant's pick.
    if (swiper.autoplay && swiper.autoplay.stop) swiper.autoplay.stop();

    if (swiper.params && swiper.params.loop) {
      // Defensive rebuild: if loop duplicates are missing for any reason,
      // slideToLoop may no-op. Rebuild before navigating.
      var hasDuplicates = !!container.querySelector('.swiper-slide-duplicate');
      if (!hasDuplicates) {
        if (swiper.loopDestroy) swiper.loopDestroy();
        if (swiper.loopCreate) swiper.loopCreate();
        if (swiper.update) swiper.update();
      }
      if (swiper.slideToLoop) swiper.slideToLoop(realIndex);
    } else {
      if (swiper.slideTo) swiper.slideTo(realIndex);
    }
  }

  /**
   * Handles a `brand-editor:select-element` message by locating the block
   * and, if it lives inside a Swiper carousel, driving the Swiper to it.
   * No-op for section selections or for elements outside a Swiper.
   * @param {{ elementType?: string, id?: string }} detail - Message payload.
   */
  function handlePreviewSelectElement(detail) {
    if (!detail || !detail.id) return;
    // Sections aren't slides; only block selections navigate a carousel.
    if (detail.elementType !== 'block') return;

    var element = document.querySelector('[data-block-id="' + detail.id + '"]');
    if (!element) return;

    // `.js-carousel-slider` covers featured-categories / featured-brands
    // carousels that don't use `.swiper-container` as their root.
    var container = element.closest('.swiper-container, .js-carousel-slider');
    if (!container) return;

    try {
      driveSwiperToSlideForSelection(container, element);
    } catch (e) {
      console.warn('[store] driveSwiperToSlideForSelection failed', e);
    }
  }

  /**
   * Registers the postMessage listener. Filtered to messages from our
   * embedding parent window only (the Brand Editor host frame), plus
   * namespaced message types, so third-party scripts on the page can't
   * trigger reconciliation or navigation. Origin can't be used as the
   * filter here because the preview iframe is loaded via srcdoc and its
   * origin is opaque / inherited in ways that vary by browser.
   */
  function initPreviewMessageListener() {
    window.addEventListener('message', function(event) {
      // Not embedded → nothing should be dispatching this message; ignore.
      if (window.parent === window) return;
      // Must come from the embedding parent (Brand Editor), not from the
      // page itself or another iframe.
      if (event.source !== window.parent) return;
      if (!event.data || typeof event.data !== 'object') return;

      switch (event.data.type) {
        case 'brand-editor:select-element':
          handlePreviewSelectElement(event.data);
          break;
      }
    });
  }

  /* ========================================
   * INITIALIZE
   * ========================================
   */

  function initPinterestShare() {
    document.addEventListener('click', function(e) {
      var btn = e.target.closest('.js-pinterest-share');
      if (!btn) return;
      e.preventDefault();
      var hidden = btn.nextElementSibling;
      var link = hidden && hidden.querySelector('a');
      if (link) window.open(link.href, '_blank', 'noopener,noreferrer');
    });
  }

  function initHeroParallax() {
    var desktopMQ = window.matchMedia('(min-width: 768px)');
    var reducedMQ = window.matchMedia('(prefers-reduced-motion: reduce)');

    function shouldRun() {
      return desktopMQ.matches && !reducedMQ.matches;
    }

    function updateParallax() {
      var visuals = document.querySelectorAll('.js-hero-parallax');
      if (!visuals.length) return;
      if (!shouldRun()) {
        visuals.forEach(function(visual) { visual.style.transform = ''; });
        return;
      }
      var stickyWrapper = document.querySelector('.sticky-header-wrapper');
      var headerH = stickyWrapper ? stickyWrapper.getBoundingClientRect().height : 0;
      visuals.forEach(function(visual) {
        var rect = visual.parentElement.getBoundingClientRect();
        visual.style.transform = 'translateY(' + (-(rect.top - headerH) * 0.15) + 'px)';
      });
    }

    // Idempotent: remove any previous listener before registering a new one
    if (heroParallaxScrollHandler) {
      window.removeEventListener('scroll', heroParallaxScrollHandler);
      heroParallaxScrollHandler = null;
    }

    // Skip binding if no parallax heroes are present on this page
    if (!document.querySelector('.js-hero-parallax')) return;

    var ticking = false;
    heroParallaxScrollHandler = function() {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(function() {
        updateParallax();
        ticking = false;
      });
    };

    window.addEventListener('scroll', heroParallaxScrollHandler, { passive: true });
    updateParallax();
  }

  function init() {
    // Initialize modal handler first
    initModalHandler();
    
    // CORE
    initStickyHeader();
    initDesktopNav();
    initDesktopDropdownHeight();
    initHeaderDropdownPosition();
    initNavigationBars();
    initNavToggles();
    initSlimHeaderOnScroll();
    initSearchTrigger();
    initNotificationObserver();
    initNotificationScrollListener();
    initInactiveTabMessage();

    // SECTIONS
    initSwipers();
    initHeroParallax();

    initCountdown();
    initTimerOffers();
    initVideoBlocks();
    initProductDescriptionToggle();
    initAdbar();
    initPromotionalModal();

    // CATEGORY
    initProductItemSliders();
    initInfiniteScroll();
    initStickyCategoryControls();
    initQuickshop();
    initProductListVariantHandler();

    // PRODUCT (PDP)
    initProductGallery();
    initStickyProductGallery();
    initProductVideo();
    initNativeVideos();
    initProductVariants();
    noStockVariants();
    initQuantitySelectors();
    initContactRedirect();
    initPinterestShare();
    initAddToCart();
    initShippingCalculator();
    initCartItemActions();
    initCartFavicon();
    initFreeShippingProgress();
    calculateCartShippingOnLoad();
    initProductRecommendations();

    // PREVIEW (Brand Editor)
    initPreviewMessageListener();
  }

  DOMContentLoaded.addEventOrExecute(init);

})();
