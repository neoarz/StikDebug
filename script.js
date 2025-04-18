document.addEventListener('DOMContentLoaded', () => {
  // Set active class on current page's nav link
  const currentPath = window.location.pathname;
  const navLinks = document.querySelectorAll('.navbar nav a, .mobile-menu nav a');
  
  navLinks.forEach(link => {
    const linkPath = link.getAttribute('href');
    if (currentPath.endsWith(linkPath) || 
        (currentPath.endsWith('/') && linkPath === 'index.html') ||
        (currentPath === '' && linkPath === 'index.html')) {
      link.classList.add('active');
    }
  });

  // Mobile menu toggle - enhanced for dropdown style
  const menuToggle = document.querySelector('.menu-toggle');
  const mobileMenu = document.querySelector('.mobile-menu');
  
  console.log('Menu toggle found:', menuToggle !== null);
  console.log('Mobile menu found:', mobileMenu !== null);
  
  if (menuToggle && mobileMenu) {
    // Only add visible class if we're on mobile
    if (window.innerWidth <= 768) {
      menuToggle.classList.add('visible');
    }
    
    // Update visibility on resize
    window.addEventListener('resize', () => {
      if (window.innerWidth <= 768) {
        menuToggle.classList.add('visible');
      } else {
        menuToggle.classList.remove('visible');
        menuToggle.classList.remove('menu-active');
        mobileMenu.classList.remove('show');
      }
    });
    
    menuToggle.addEventListener('click', (e) => {
      console.log('Menu toggle clicked');
      e.preventDefault();
      e.stopPropagation();
      menuToggle.classList.toggle('menu-active');
      mobileMenu.classList.toggle('show');
      
      // Force repaint to ensure transitions work properly
      void mobileMenu.offsetWidth;
    });
    
    // Close menu when clicking on a mobile menu link
    const mobileLinks = document.querySelectorAll('.mobile-menu nav a');
    mobileLinks.forEach(link => {
      link.addEventListener('click', () => {
        menuToggle.classList.remove('menu-active');
        mobileMenu.classList.remove('show');
      });
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', (event) => {
      if (mobileMenu.classList.contains('show') && 
          !mobileMenu.contains(event.target) && 
          !menuToggle.contains(event.target)) {
        menuToggle.classList.remove('menu-active');
        mobileMenu.classList.remove('show');
      }
    });
  }

  // FAQ Accordion Functionality
  const accordionItems = document.querySelectorAll('.faq-accordion-item');
  
  if (accordionItems.length) {
    // Open the first FAQ item by default
    accordionItems[0].classList.add('active');
    
    accordionItems.forEach(item => {
      const header = item.querySelector('.faq-accordion-header');
      
      header.addEventListener('click', () => {
        const isActive = item.classList.contains('active');
        
        // Close all accordion items
        accordionItems.forEach(accItem => {
          accItem.classList.remove('active');
        });
        
        // If the clicked item wasn't active, make it active
        if (!isActive) {
          item.classList.add('active');
        }
      });
    });
  }
  
  // Error Code Search Functionality
  const errorSearchInput = document.getElementById('errorCodeSearch');
  const errorCodeItems = document.querySelectorAll('.error-code-item');
  const errorFFICodes = document.querySelectorAll('.error-ffi-codes code');
  
  if (errorSearchInput && (errorCodeItems.length || errorFFICodes.length)) {
    errorSearchInput.addEventListener('input', function() {
      const searchTerm = this.value.toLowerCase().trim();
      
      // Search error code items
      errorCodeItems.forEach(item => {
        const codeText = item.textContent.toLowerCase();
        if (searchTerm === '' || codeText.includes(searchTerm)) {
          item.style.display = 'block';
        } else {
          item.style.display = 'none';
        }
      });
      
      // Search FFI code items
      errorFFICodes.forEach(code => {
        const codeText = code.textContent.toLowerCase();
        if (searchTerm === '' || codeText.includes(searchTerm)) {
          code.style.display = 'inline-block';
        } else {
          code.style.display = 'none';
        }
      });
    });
  }
  
  // Smooth scrolling for FAQ navigation links
  const faqNavLinks = document.querySelectorAll('.faq-nav-item');
  
  if (faqNavLinks.length) {
    faqNavLinks.forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        
        const targetId = link.getAttribute('href');
        const targetElement = document.querySelector(targetId);
        
        if (targetElement) {
          // Add some offset to account for the sticky navbar
          const navbarHeight = document.querySelector('.navbar').offsetHeight;
          const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - navbarHeight - 20;
          
          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });
          
          // Update URL without page refresh
          history.pushState(null, null, targetId);
        }
      });
    });
  }

  // Improved Image Carousel in Hero Section
  const carouselSetup = () => {
    const slides = document.querySelectorAll('.carousel-slide');
    const track = document.querySelector('.carousel-track');
    
    if (!slides.length || !track) return;
    
    // Initialize carousel state
    let currentSlide = 0;
    const slideCount = slides.length;
    
    // Set initial slide positions without transitions
    slides.forEach((slide, index) => {
      // Prepare slides for animation
      slide.style.position = 'absolute';
      slide.style.width = '100%';
      slide.style.height = '100%';
      slide.style.transition = 'none'; // Disable transitions initially
      
      // Set initial positions and visibility
      if (index === 0) { // Active slide
        slide.classList.add('active');
        slide.style.transform = 'scale(1.05)';
        slide.style.opacity = '1';
        slide.style.zIndex = '3';
        slide.style.visibility = 'visible';
      } else if (index === 1) { // Next slide
        slide.classList.add('next');
        slide.style.transform = 'translateX(60%) scale(0.85)';
        slide.style.opacity = '0.5';
        slide.style.zIndex = '2';
        slide.style.visibility = 'visible';
      } else if (index === slideCount - 1) { // Previous slide
        slide.classList.add('prev');
        slide.style.transform = 'translateX(-60%) scale(0.85)';
        slide.style.opacity = '0.5';
        slide.style.zIndex = '2';
        slide.style.visibility = 'visible';
      } else {
        slide.style.transform = 'translateX(100%) scale(0.8)'; // Position off-screen right
        slide.style.opacity = '0';
        slide.style.zIndex = '0';
        slide.style.visibility = 'hidden';
      }
    });
    
    // Enable transitions after initial positioning
    setTimeout(() => {
      slides.forEach(slide => {
        slide.style.transition = 'transform 0.4s ease, opacity 0.4s ease';
      });
    }, 50);
    
    // Function to advance to the next slide (right to left motion)
    const nextSlide = () => {
      // Calculate positions (handle wrapping around)
      const nextIndex = (currentSlide + 1) % slideCount;
      const newNextIndex = (currentSlide + 2) % slideCount;
      
      // 1. First make the new next slide ready off-screen with no transition
      slides[newNextIndex].style.transition = 'none';
      slides[newNextIndex].style.transform = 'translateX(100%) scale(0.8)';
      slides[newNextIndex].style.opacity = '0';
      slides[newNextIndex].style.visibility = 'hidden';
      
      // Force repaint to ensure the no-transition positioning takes effect
      void slides[newNextIndex].offsetWidth;
      
      // 2. Re-enable transitions for the upcoming animation
      slides[newNextIndex].style.transition = 'transform 0.4s ease, opacity 0.4s ease';
      
      // 3. Now move all visible slides one position left
      // Current active slide becomes previous
      slides[currentSlide].classList.remove('active');
      slides[currentSlide].classList.add('prev');
      slides[currentSlide].style.transform = 'translateX(-60%) scale(0.85)';
      slides[currentSlide].style.opacity = '0.5';
      slides[currentSlide].style.zIndex = '2';
      
      // Current next slide becomes active
      slides[nextIndex].classList.remove('next');
      slides[nextIndex].classList.add('active');
      slides[nextIndex].style.transform = 'scale(1.05)';
      slides[nextIndex].style.opacity = '1';
      slides[nextIndex].style.zIndex = '3';
      
      // New next slide fades in from the right
      slides[newNextIndex].classList.add('next');
      slides[newNextIndex].style.visibility = 'visible';
      slides[newNextIndex].style.transform = 'translateX(60%) scale(0.85)';
      slides[newNextIndex].style.opacity = '0.5';
      slides[newNextIndex].style.zIndex = '2';
      
      // The old prev slide moves off-screen to the left and hides
      const oldPrevIndex = (currentSlide - 1 + slideCount) % slideCount;
      slides[oldPrevIndex].classList.remove('prev');
      slides[oldPrevIndex].style.transform = 'translateX(-120%) scale(0.7)';
      slides[oldPrevIndex].style.opacity = '0';
      slides[oldPrevIndex].style.zIndex = '1';
      
      // Hide the old prev slide after transition completes
      setTimeout(() => {
        slides[oldPrevIndex].style.visibility = 'hidden';
      }, 400);
      
      // Update current slide index
      currentSlide = nextIndex;
    };
    
    // Function to go to the previous slide (left to right motion)
    const prevSlide = () => {
      // Calculate positions (handle wrapping around)
      const prevIndex = (currentSlide - 1 + slideCount) % slideCount;
      const newPrevIndex = (currentSlide - 2 + slideCount) % slideCount;
      
      // 1. First make the new prev slide ready off-screen with no transition
      slides[newPrevIndex].style.transition = 'none';
      slides[newPrevIndex].style.transform = 'translateX(-100%) scale(0.8)';
      slides[newPrevIndex].style.opacity = '0';
      slides[newPrevIndex].style.visibility = 'hidden';
      
      // Force repaint to ensure the no-transition positioning takes effect
      void slides[newPrevIndex].offsetWidth;
      
      // 2. Re-enable transitions for the upcoming animation
      slides[newPrevIndex].style.transition = 'transform 0.4s ease, opacity 0.4s ease';
      
      // 3. Now move all visible slides one position right
      // Current active slide becomes next
      slides[currentSlide].classList.remove('active');
      slides[currentSlide].classList.add('next');
      slides[currentSlide].style.transform = 'translateX(60%) scale(0.85)';
      slides[currentSlide].style.opacity = '0.5';
      slides[currentSlide].style.zIndex = '2';
      
      // Current prev slide becomes active
      slides[prevIndex].classList.remove('prev');
      slides[prevIndex].classList.add('active');
      slides[prevIndex].style.transform = 'scale(1.05)';
      slides[prevIndex].style.opacity = '1';
      slides[prevIndex].style.zIndex = '3';
      
      // New prev slide fades in from the left
      slides[newPrevIndex].classList.add('prev');
      slides[newPrevIndex].style.visibility = 'visible';
      slides[newPrevIndex].style.transform = 'translateX(-60%) scale(0.85)';
      slides[newPrevIndex].style.opacity = '0.5';
      slides[newPrevIndex].style.zIndex = '2';
      
      // The old next slide moves off-screen to the right and hides
      const oldNextIndex = (currentSlide + 1) % slideCount;
      slides[oldNextIndex].classList.remove('next');
      slides[oldNextIndex].style.transform = 'translateX(120%) scale(0.7)';
      slides[oldNextIndex].style.opacity = '0';
      slides[oldNextIndex].style.zIndex = '1';
      
      // Hide the old next slide after transition completes
      setTimeout(() => {
        slides[oldNextIndex].style.visibility = 'hidden';
      }, 400);
      
      // Update current slide index
      currentSlide = prevIndex;
    };
    
    // Set up automatic carousel rotation
    const intervalTime = 4000; // 4 seconds between slides
    let carouselInterval = setInterval(nextSlide, intervalTime);
    
    // Interaction with carousel
    const carouselContainer = document.querySelector('.carousel-container');
    if (carouselContainer) {
      // Pause carousel on hover
      carouselContainer.addEventListener('mouseenter', () => {
        clearInterval(carouselInterval);
      });
      
      carouselContainer.addEventListener('mouseleave', () => {
        clearInterval(carouselInterval);
        carouselInterval = setInterval(nextSlide, intervalTime);
      });
      
      // Add touch/swipe navigation
      let touchStartX = 0;
      let touchEndX = 0;
      
      carouselContainer.addEventListener('touchstart', (e) => {
        touchStartX = e.changedTouches[0].screenX;
        clearInterval(carouselInterval);
      }, {passive: true});
      
      carouselContainer.addEventListener('touchend', (e) => {
        touchEndX = e.changedTouches[0].screenX;
        handleSwipe();
        clearInterval(carouselInterval);
        carouselInterval = setInterval(nextSlide, intervalTime);
      }, {passive: true});
      
      const handleSwipe = () => {
        const swipeThreshold = 50;
        if (touchEndX < touchStartX - swipeThreshold) {
          // Swipe left - go to next slide
          nextSlide();
        } else if (touchEndX > touchStartX + swipeThreshold) {
          // Swipe right - go to previous slide
          prevSlide();
        }
      };

      // Add click navigation 
      carouselContainer.addEventListener('click', (e) => {
        const containerWidth = carouselContainer.clientWidth;
        const clickX = e.offsetX;
        
        if (clickX < containerWidth / 3) {
          // Click on left third - go to previous slide
          prevSlide();
        } else if (clickX > (containerWidth * 2/3)) {
          // Click on right third - go to next slide
          nextSlide();
        }
      });
    }
  };
  
  // Initialize carousel when DOM is loaded
  carouselSetup();

  // Animation for sections on scroll
  const sections = document.querySelectorAll('section');
  
  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  };
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
      }
    });
  }, observerOptions);
  
  sections.forEach(section => {
    section.style.opacity = '0';
    section.style.transform = 'translateY(20px)';
    section.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(section);
  });
  
  // Current year for copyright
  const currentYear = new Date().getFullYear();
  const copyrightElement = document.querySelector('footer p');
  
  if (copyrightElement) {
    copyrightElement.textContent = copyrightElement.textContent.replace('2025', currentYear);
  }
  
  // Alternative approach for year element
  const yearElement = document.getElementById('current-year');
  if (yearElement) {
    yearElement.textContent = currentYear;
  }

  // Add active class to current page's nav link based on data-page attribute
  const body = document.body;
  if (body.hasAttribute('data-page')) {
    const currentPage = body.getAttribute('data-page');
    document.querySelectorAll('.navbar nav a, .mobile-menu nav a').forEach(link => {
      const href = link.getAttribute('href');
      if (href && href.includes(currentPage + '.html')) {
        link.classList.add('active');
      }
    });
  }
  
  // Platform download options functionality for download page
  const downloadOptions = document.querySelectorAll('.download-option');
  const platformDetails = document.querySelectorAll('.platform-instructions details');
  
  if (downloadOptions.length && platformDetails.length) {
    // Store original hrefs to allow downloads to work
    downloadOptions.forEach(option => {
      const originalHref = option.getAttribute('href');
      option.dataset.downloadUrl = originalHref;
      
      option.addEventListener('click', (e) => {
        // Prevent the default behavior to handle navigation manually
        e.preventDefault();
        
        // Determine which platform was clicked
        const platformClasses = Array.from(option.querySelector('.platform-icon').classList);
        let platform = '';
        
        if (platformClasses.includes('windows')) {
          platform = 'Windows';
        } else if (platformClasses.includes('macos')) {
          platform = 'macOS';
        } else if (platformClasses.includes('linux')) {
          platform = 'Linux';
        }
        
        // Find and open the matching details element
        platformDetails.forEach(detail => {
          const summaryText = detail.querySelector('summary').textContent;
          if (summaryText.includes(platform)) {
            // Close all details first
            platformDetails.forEach(d => d.removeAttribute('open'));
            // Open the selected one
            detail.setAttribute('open', true);
            
            // Scroll to the details element
            setTimeout(() => {
              detail.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }, 100);
          }
        });
        
        // Continue with the download after a short delay
        setTimeout(() => {
          window.location.href = option.dataset.downloadUrl;
        }, 300);
      });
    });
  }
});