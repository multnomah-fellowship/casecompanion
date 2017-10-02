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
//= require materialize/jquery.easing.1.4
//= require materialize/velocity.min
//= require materialize/global
//= require materialize/forms
//= require materialize/character_counter
//= require materialize/dropdown
//= require_tree .

const analytics = {
  trackView: function(e) {
    const url = e.target.URL;

    ga('send', 'pageview', url);
    mixpanel.track('pageview');
  },

  trackExpand: function(caption) {
    mixpanel.track('expand', { caption: caption });
  }
}

window.App = (function() {
  const toggleDropdown = function(id, visible) {
    const $hiddenDiv = $('#expand-' + id.replace('#', ''));
    const $targetLink = $('[href="' + id + '"]');
    const $dropdown = $hiddenDiv.closest('.app-dropdown');
    const $icon = $targetLink.find('i');

    if (visible) {
      // show it!
      $hiddenDiv.attr('style', 'display: block');
      $icon.text('–');

      // store the location in the URL
      const newLocation = window.location.pathname + id;
      const pageTitle = document.getElementsByTagName("title")[0].innerText;
      history.replaceState({}, "My Advocate", newLocation);

      // track mixpanel
      const text = $targetLink.find('span').text();
      analytics.trackExpand(text);
    } else {
      // hide it!
      $hiddenDiv.attr('style', 'display: none');
      $icon.text('+');
    }
  };

  const handleToggle = function(e) {
    const $targetLink = $(e.target).closest('a');
    const $hiddenDiv = $("#expand-" + $targetLink.attr('href').replace('#', ''));

    toggleDropdown($targetLink.attr('href'), !$hiddenDiv.is(':visible'))

    return false;
  };

  const handleTableClick = function(e) {
    const $el = $(e.target);
    const $tr = $el.closest('tr');

    Turbolinks.visit($tr.attr('data-href'));
  };

  const initializeDropdowns = function() {
    $(document).on('click', '.app-dropdown__link', handleToggle);

    if ($("#expand-" + window.location.hash.replace('#', '')).length) {
      toggleDropdown(window.location.hash, true);
    }
  };

  const initializeSignatureField = function() {
    // When the "By checking this box[...]" box is checked, we want to select
    // the text field by default.
    const handleSignatureChecked = function(e) {
      const $attachmentField = $('#rights_flow_electronic_signature_name');

      if ($(e.target).is(':checked')) {
        $attachmentField.select();
      }
    };

    // When the signature "Type your name" field is selected, we want to turn
    // the form attachment's background blue.
    const handleSignatureFieldSelected = function(e) {
      const $attachmentContainer = $(e.target).closest('.app-field-attachment');
      const isSelected = e.type == "select";

      $attachmentContainer.toggleClass('app-field-attachment--active', isSelected);
    };

    $(document).on('change', '#rights_flow_electronic_signature_checked', handleSignatureChecked);
    $(document).on('select', '#rights_flow_electronic_signature_name', handleSignatureFieldSelected);
    $(document).on('blur', '#rights_flow_electronic_signature_name', handleSignatureFieldSelected);
  };

  const initializeReveals = function() {
    const handleReveal = function(e) {
      e.preventDefault();

      const $link = $(e.target).closest('a');
      const $target = $($link.attr('href'));
      const text = $link.text();

      $link.addClass('hide');
      $target.removeClass('hide');
      analytics.trackExpand(text);
    };

    $(document).on('click', '.app-reveal', handleReveal);
  };

  const initializeButtonSpinners = function() {
    const handleButtonClick = function(e) {
      const $target = $(e.target);
      $target.addClass('app-button--loading');

      if ($target.attr('href') === '#') {
        e.preventDefault();
        e.stopPropagation();
      }
    };

    $(document).on('click', '.app-button[data-app-spinner]', handleButtonClick);
  };

  return {
    init: function() {
      // Beware: This is only called once on initial page load, and subsequent
      // turbolinks navigations will not call this method again. All event
      // handlers registered in here should use [Event
      // Delegation](https://learn.jquery.com/events/event-delegation/)
      initializeDropdowns();

      initializeReveals();

      initializeButtonSpinners();

      initializeSignatureField();

      // In case the user hits the back button and there are pre-filled values
      // on the previous page:
      Materialize.updateTextFields();

      $(document).on('click', 'tr[data-href]', handleTableClick);
    },

    onPageLoad: function(e) {
      // This method is called after a page is loaded, either for the first time
      // or via turbolinks.
      //
      // Since turbolinks effectively turns this site into a single-page app,
      // any event listeners created here for elements on this page should be
      // removed on `onPageOffload`.
      $('select').material_select();

      analytics.trackView(e);
    },

    onPageOffload: function() {
      $('select').material_select('destroy');
    }
  };
})();

document.addEventListener('turbolinks:load', window.App.onPageLoad);
document.addEventListener('turbolinks:visit', window.App.onPageOffload);

// Initialize the app on the first load only.
window.addEventListener('load', window.App.init);
