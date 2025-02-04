/* ==========================================================================
   Sidebar navigation and visualization helper scripts
   ========================================================================== */

$(function () {
  // FIXME: How to get the real base URL (without using Liquid and Front Matter) ?!?!
  const docRootName = 'doc';
  const notFoundPageName = '404.html';
  const contentID = 'article';

  function adjustSidebars() {
    // Identify the URL of the loaded page
    var loadedPageUrl = window.location.pathname;

    // Get the "sidebar" element
    var sidebarElement = document.querySelector('.sidebar');
    // If "sidebar" element exists, find the corresponding navigator item within it
    if (sidebarElement) {
      // Get all <a> elements in the navigation list within the "sidebar"
      var navLinks = sidebarElement.querySelectorAll('.nav__list .nav-link');

      // Enumerate through each <a> element and remove the "active" class
      navLinks.forEach(navLink => {
        navLink.classList.remove('active');
      });

      // Find the corresponding navigator item with matching URL within the "sidebar"
      var matchingNavItem = sidebarElement.querySelector('.nav__list .nav-link[href="' + loadedPageUrl + '"]');

      // If a matching item is found, mark it as "active"
      if (matchingNavItem) {
        matchingNavItem.classList.add('active');

        // Sync the browser title too
        title = matchingNavItem.text;
        if (title)
          window.top.document.title = title;

        // Expand all parent ul elements up to the nearest .nav__list
        var parentUl = matchingNavItem.closest('ul');
        while (parentUl) {
          var parentCheckbox = parentUl.previousElementSibling.previousElementSibling;
          if (parentCheckbox && parentCheckbox.tagName === 'INPUT' && parentCheckbox.type === 'checkbox')
            parentCheckbox.checked = true;

          // Check if we reached the top most list container item that is an <ul> with class 'nav__list'
          var immediateParent = parentUl.parentElement;
          if (immediateParent.classList.contains('nav__list'))
            break;

          parentUl = immediateParent.closest('ul');
        }

        // Ensure the active item is visible within the "sidebar"
        // TODO: This one is also not too reliable, browser dependant, get a better solution
        matchingNavItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }

      // TOC is autogenerated via 'include toc.html' so its size is not known prior the call of toc.html
      // Signal emptiness, css will hide if needed based on it and config settings
      // NOTE: Not hiding directly here to behave the same way like the left sidebar does
      var tocElement = document.querySelector('.toc');
      if (tocElement) {
        var tocMenuElement = tocElement.querySelector('.toc__menu');
        if (null == tocMenuElement || false == tocMenuElement.hasChildNodes)
          tocElement.classList.add('empty');
      }
    }
  }

  // Function to apply all of our custom modifications on the self loaded pages
  function finalizeContent(anchorId) {
    // Sync the sidebar with the current page url, migth be out of sync when the page is loaded initially from an inner url
    adjustSidebars();
    // There might be nav-links in the loaded new content as well (e.g.Next / Prev buttons
    // so, handle the links here as the last action
    updateNavLinks();
    // Add page heading anchors
    addPageAnchors();
    // Add toc to anchor scrolling
    addTOCScrolling();
    // Add code block enhancements
    if (ClipboardJS.isSupported())
      addCodeBlocksTitle();
    // Add content tooltips
    addContentTooltips();
    // Try to scroll to a giben anchor, if any
    if (anchorId)
      scrollToAnchor(anchorId);
  }

  // Function to load content based on relative URL
  function loadContentFromUrl(url, onSuccess, onError) {
    fetch(url)
      .then(response => {
        if (false == response.ok) {
          if (response.status == 404 && url.toLowerCase().indexOf(notFoundPageName) === -1)
            throw new Error(response.status);
          else
            throw new Error('Server returned ' + response.status);
        }
        return response.text();
      })
      .then(html => {
        // Parse the HTML string to create a DOM document
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, 'text/html');
        // Find the "article" element in the parsed document
        var newContent = doc.querySelector(contentID);
        onSuccess(newContent);
      })
      .catch(error => {
        onError(error);
      });
  }

  function scrollToAnchor(anchorId) {
    var anchorElement = document.getElementById(anchorId);
    if (anchorElement) {
      // Use the attached smooth scroll to have a consistent behavior
      smoothScroll.animateScroll(anchorElement, null, { updateURL: false });
    }
  }

  function anchorIDFromUrl(url) {
    var anchorId = null;
    var hash = url.hash;
    if (hash && hash.length > 0) {
      var hashIndex = hash.indexOf('#');
      if (hashIndex !== -1)
        anchorId = hash.substring(hashIndex + 1);
    }
    return anchorId;
  }

  function updateContentFromUrl(url) {
    var currContent = document.querySelector(contentID);

    loadContentFromUrl(
      url,
      newContent => {
        // FIXME: This does not work, double check
        currContent.scrollTop;
        // As a workaround of the above, empty the old content, and with a short delay only, load the new one
        currContent.innerHTML = '';

        // Replace the old content, but only with a small delay, to make sure the content reset takes effect
        setTimeout(function () {
          // Replace the old content with the loaded content
          currContent.parentNode.replaceChild(newContent, currContent);

          // Add all our custom modifications to all the self loaded pages
          finalizeContent(anchorIDFromUrl(url));
        }, 100);
      },
      error => {
        if (error == "Error: 404") {
          var baseURL = window.location.origin;
          var notFoundURL = baseURL + '/' + docRoot + '/' + notFoundPageName;

          updateContentFromUrl(notFoundURL);
        }
        else {
          currContent.innerHTML = '<h3>Sorry, there was a problem loading the content!</h3>(' + error + ')';
          console.error("Error loading content, " + error)
        }
      }
    );
  }

  function getCollectionFromDocPath(url) {
    var parts = url.href.split('/');
    var docIndex = parts.indexOf(docRootName);

    // If 'doc' is not found or it's the last segment, return an empty string
    if (docIndex === -1 || docIndex === parts.length - 1) {
      return '';
    }

    return parts[docIndex + 1];
  }

  function sameCollection(url1, url2) {
    var collection1 = getCollectionFromDocPath(url1);
    var collection2 = getCollectionFromDocPath(url2);

    return collection1 === collection2;
  }

  // Function to handle link clicks
  function handleNavLinkClick(event) {
    if (!event.shiftKey && !event.ctrlKey && !event.altKey && !event.metaKey) {

      // Get the relative URL value and update the browser URL
      // Use originalTarget or explicitTarget to get the correct one even for clicks from the tooltips
      var anchorElement = event.originalTarget.closest('a');

      if (anchorElement) {
        var url = new URL(anchorElement.href);

        // Try to load into the inner content frame only if the collection has not changed
        // Otherwise let the original click flow take effect, as the nav bar must be reloaded too
        // for a different collection
        if (sameCollection(url, window.location)) {
          // Prevent default navigation behavior, we will use our content load method
          event.preventDefault();

          var urlStr = url.pathname + url.hash;
          var changed = (urlStr != window.location.pathname + window.location.hash);

          // Update the browser URL
          history.pushState(null, null, url);

          // Load content based on the updated relative URL
          // but only if the url has changed
          if (changed)
            updateContentFromUrl(url);
        }
        // Clear focus from the clicked element, as we have other visualization for the selected items
        event.target.blur();
      }
      else
        console.debug("Different collection item requested, loading full page...")
    }
  }

  function updateNavLinks(event) {
    // Attach click event listeners to all links with class 'nav-link'
    var navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(function (link) {
      link.addEventListener('click', handleNavLinkClick);
    });
  }

  const smoothScrollTopOffset = 100;
  var smoothScroll = new SmoothScroll('a[href*="#"]', {
    offset: smoothScrollTopOffset,
    speed: 400,
    speedAsDuration: true,
    durationMax: 500
  });

  // TOC smooth scrolling
  function addTOCScrolling() {
    // Gumshoe scroll spy init
    if ($("nav.toc a").length > 0) {
      var spy = new Gumshoe("nav.toc a", {
        // Active classes
        navClass: "active", // applied to the nav list item
        contentClass: "active", // applied to the content

        // Nested navigation
        nested: false, // if true, add classes to parents of active link
        nestedClass: "active", // applied to the parent items

        // Offset & reflow
        offset: smoothScrollTopOffset, // how far from the top of the page to activate a content area
        reflow: true, // if true, listen for reflows

        // Event support
        events: true // if true, emit custom events
      });
    }
  }

  // Add anchors for headings
  function addPageAnchors() {
    // FIXME: This magic 6 must be maintained together now with generate_links.rb (and other places ?!)
    $('.page__content').find('h1, h2, h3, h4, h5, h6').each(function () {
      var id = $(this).attr('id');
      if (id) {
        var anchor = document.createElement("a");
        anchor.className = 'header-link';
        anchor.href = '#' + id;
        anchor.innerHTML = '<span class=\"sr-only\">Permalink</span><i class=\"fab fa-slack-hash\"></i>';
        anchor.title = "Permalink";
        $(this).append(anchor);
      }
    });
  }

  function alterPageTitle(content) {
    let tempContainer = document.createElement('div');
    tempContainer.innerHTML = content;

    // Remove/Override some default title style formatting to look better in the tooltip
    const pageTitle = tempContainer.querySelector('#page-title');
    if (pageTitle)
      pageTitle.style.marginTop = '1em';

    const pageSubtitle = tempContainer.querySelector('#page-subtitle');
    if (pageSubtitle)
      pageSubtitle.style.borderBottom = '0px';

    return tempContainer.innerHTML;
  }

  function loadContentPartFrom(url, onSuccess, onError) {
    // If no anchor with heading id, use the page title with id=""
    var startHeadingId = 'page-title'
    // Extract the anchor part of the URL
    var hashIndex = url.indexOf('#');
    var hasAnchor = (hashIndex !== -1);

    if (hasAnchor)
      startHeadingId = url.substring(hashIndex + 1);

    loadContentFromUrl(
      url,
      newContent => {
        var startHeading = newContent.querySelector('#' + startHeadingId);
        if (startHeading) {
          var content = startHeading.outerHTML; // Include the starting <h> element itself

          var nextSibling = startHeading.nextElementSibling;
          // Collect all siblings until the next heading or the end of the document
          // FIXME: This magic 6 must be maintained together now with generate_links.rb (and other places ?!)
          while (nextSibling && nextSibling.tagName !== 'H1' && nextSibling.tagName !== 'H2' && nextSibling.tagName !== 'H3' && nextSibling.tagName !== 'H4' && nextSibling.tagName !== 'H5' && nextSibling.tagName !== 'H6') {
            content += nextSibling.outerHTML;
            nextSibling = nextSibling.nextElementSibling;
          }
          if (false == hasAnchor)
            content = alterPageTitle(content);

          onSuccess(content);
        }
        else
          console.error('Start heading not found by ID: ' + startHeadingId);
      },
      error => {
        error(error);
      }
    );
  }

  // Tooltip generation and handling
  const toolTipArrowSize = 10;
  var tooltip = null;
  var tooltipTarget = null;
  var shouldShowTooltip = false;
  var showTimeoutFuncID;
  var hideTimeoutFuncID;

  function getTooltipPos(event, tooltipTarget) {
    const mouseX = event.clientX; 
    const rect = tooltipTarget.getBoundingClientRect();
    var computedStyle = window.getComputedStyle(tooltipTarget);
    var lineHeight = parseFloat(computedStyle.getPropertyValue('line-height'));

    var pos = new DOMPoint();
    pos.x = mouseX; // Use now mouse X instead - Math.max(0, pos.x + document.documentElement.scrollLeft + rect.left);
    // If the occupied space of the tooltip target is bigger than its line height, it means it spanws to multiple lines
    // align to the upper line part in that case if the mouse is on the right side of the middle of its rect, otherwise align to the bottom row part
    var multilineUpperPart = (rect.height > lineHeight && mouseX > rect.x + rect.width / 2);
    pos.y = pos.y + document.documentElement.scrollTop + rect.top + rect.height / (multilineUpperPart ? 2 : 1);

    return pos;
  }

  function setArrowPosition(posName, position) {
    var newPosition = position + 'px';
    tooltip.style.setProperty(posName, newPosition);
  }
  
  function showTooltip(event, tooltipText) {
    tooltip.innerHTML = tooltipText.innerHTML;

    var tooltipPos = getTooltipPos(event, tooltipTarget)
    var tooltipArrowLeftShift = 2 * toolTipArrowSize;
      
    setArrowPosition('--tooltip-arrow-top', -1 * toolTipArrowSize);
    setArrowPosition('--tooltip-arrow-left', tooltipArrowLeftShift + toolTipArrowSize / 2);

    tooltip.style.left = tooltipPos.x - 2 * tooltipArrowLeftShift + 'px';
    tooltip.style.top = tooltipPos.y + toolTipArrowSize + 'px';

    shouldShowTooltip = true;

    clearTimeout(hideTimeoutFuncID);
    clearTimeout(showTimeoutFuncID);
    showTimeoutFuncID = setTimeout(function () {
      if (shouldShowTooltip) {
        // Size is still not yet calculated correctly here
        // var rect = tooltip.getBoundingClientRect();
        // tooltip.style.top = (tooltipPos.y + rect.height) + 'px';
        // tooltip.style.left = (tooltipPos.x + rect.width / 2) + 'px';

        tooltip.classList.add('visible');
      }
    }, 100);
  }

  function shouldHideTooltip(activeTarget) {
    return ((tooltipTarget == null || activeTarget != tooltipTarget) && (tooltip == null || (activeTarget != tooltip && activeTarget.closest('.tooltip') == null)));
  }
  
  function hideTooltip(withDelay) {
    function doHideTooltip() {
      if (false == shouldShowTooltip && tooltip)
        tooltip.classList.remove('visible');
      tooltipTarget = null;
    }
    
    shouldShowTooltip = false;

    if (withDelay) {
      clearTimeout(hideTimeoutFuncID);
      hideTimeoutFuncID = setTimeout(function () {
        doHideTooltip();
      }, 25); // Give a small chance to move inside the tooltip (e.g. to allow click on links inside it)
    }
    else
      doHideTooltip();
  }

  function addContentTooltips() {
    var tooltipElements = document.querySelectorAll('.content-tooltip');
    tooltip = document.getElementById('tooltip');
    hideTooltip();

    tooltipElements.forEach(function (element) {
      var tooltipText = document.createElement('span');
      tooltipText.className = 'tooltip-text';
      tooltipText.textContent = "";
      element.appendChild(tooltipText);

      element.addEventListener('mouseover', function (event) {
        tooltipTarget = element;

        // Load only once per page load
        if (tooltipText.innerHTML === '') {
          var url = element.href;
          loadContentPartFrom(
            url,
            newContent => {
              // remove unnecessary inner content tooltips
              newContent = newContent.replace(/\bcontent-tooltip\b/g, '');
              // cache for reuse
              tooltipText.innerHTML = newContent;
              showTooltip(event, tooltipText);
            },
            error => {
              console.error('Error loading the tooltip content!' + error);
            }
          );
        }
        else
          showTooltip(event, tooltipText);
      });
    });

    document.addEventListener('mousemove', (event) => {
      if (shouldHideTooltip(event.target)) {
        if (tooltipTarget)
          hideTooltip(true)
      }
      else {
        clearTimeout(hideTimeoutFuncID);
        shouldShowTooltip = true;
      }
    });
  }

  // Make sure everything is initialized correctly on an initial load as well
  // (e.g. when an inner embedded page link is opened directly in a new tab, not via the internal navigational links)
  finalizeContent();

  // Listen for popstate events and update content accordingly
  window.addEventListener('popstate', function () {
    updateContentFromUrl(window.location.pathname);
  });

});
