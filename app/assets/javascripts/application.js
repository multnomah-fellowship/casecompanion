// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require materialize/initial
//= require materialize/global
//= require materialize/forms
//= require_tree .

const analytics = {
  trackView: function() {
    mixpanel.track('pageview');
  },

  trackExpand: function(caption) {
    mixpanel.track('expand', { caption: caption });
  }
}

window.App = (function() {
  const handleToggle = function(e) {
    const $targetLink = $(e.target).closest('a');
    const $dropdown = $targetLink.closest('.app-dropdown');
    const $icon = $dropdown.find('i');
    const $hiddenDiv = $($targetLink.attr('href'));

    if ($hiddenDiv.is(':visible')) {
      // hide it!
      $hiddenDiv.attr('style', 'display: none');
      $icon.text('+');
    } else {
      // show it!
      $hiddenDiv.attr('style', 'display: block');
      $icon.text('–');

      // track mixpanel
      const text = $dropdown.find('span').text();
      analytics.trackExpand(text);
    }

    return false;
  };

  const handleTableClick = function(e) {
    const $el = $(e.target);
    const $tr = $el.closest('tr');

    Turbolinks.visit($tr.attr('data-href'));
  };

  const initializeToggles = function() {
    $(document).on('click', 'a[href^="#expand-"]', handleToggle);
  };

  return {
    init: function() {
      // Beware: This is only called once on initial page load, and subsequent
      // turbolinks navigations will not call this method again. All event
      // handlers registered in here should use [Event
      // Delegation](https://learn.jquery.com/events/event-delegation/)
      initializeToggles();

      $(document).on('click', 'tr[data-href]', handleTableClick);
    },
  };
})();

document.addEventListener('turbolinks:load', analytics.trackView);

// Initialize the app on the first load only.
window.addEventListener('load', window.App.init);
