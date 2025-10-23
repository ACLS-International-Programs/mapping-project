// Mobile Sidebar Toggle Script
(function() {
    'use strict';
    
    // Wait for DOM to be fully loaded
    document.addEventListener('DOMContentLoaded', function() {
      
      // Only run on mobile screens
      if (window.innerWidth <= 768) {
        initializeMobileSidebar();
      }
      
      // Re-initialize on window resize
      window.addEventListener('resize', function() {
        if (window.innerWidth <= 768) {
          initializeMobileSidebar();
        }
      });
    });
    
    function initializeMobileSidebar() {
      const sidebar = document.querySelector('.sidebar');
      
      if (!sidebar) return;
      
      // Check if toggle button already exists
      if (sidebar.querySelector('.sidebar__toggle')) return;
      
      // Create toggle button
      const toggleButton = document.createElement('button');
      toggleButton.className = 'sidebar__toggle';
      toggleButton.innerHTML = 'NAVIGATION';
      toggleButton.setAttribute('aria-expanded', 'false');
      toggleButton.setAttribute('aria-label', 'Toggle navigation menu');
      
      // Wrap existing content in a collapsible container
      const content = document.createElement('div');
      content.className = 'sidebar__content';
      
      // Move all sidebar children into the content wrapper
      while (sidebar.firstChild) {
        content.appendChild(sidebar.firstChild);
      }
      
      // Add button and content back to sidebar
      sidebar.appendChild(toggleButton);
      sidebar.appendChild(content);
      
      // Toggle functionality
      toggleButton.addEventListener('click', function() {
        const isActive = content.classList.toggle('active');
        toggleButton.classList.toggle('active');
        toggleButton.setAttribute('aria-expanded', isActive);
      });
    }
  })();