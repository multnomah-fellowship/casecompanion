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
//= require material
//= require_tree .

window.App = (function() {
  const handleToggle = function(e) {
    const $targetLink = $(e.target).closest('a');
    const $listItem = $targetLink.parents('li');
    const $icon = $listItem.find('.mdl-list__item-secondary-action i');
    const $hiddenListItem = $($targetLink.attr('href'));

    if ($hiddenListItem.is(':visible')) {
      // hide it!
      $hiddenListItem.attr('style', 'display: none');
      $icon.text('keyboard_arrow_down');
    } else {
      // show it!
      $hiddenListItem.attr('style', 'display: block');
      $icon.text('keyboard_arrow_up');
    }

    return false;
  };

  const initializeToggles = function() {
    $(document).on('click', 'a[href^="#expand-"]', handleToggle);
  };

  return {
    init: function() {
      // Beware: This will be called multiple times because of turbolinks, so
      // everything in here should be idempotent
      initializeToggles();
    },
  };
})();

document.addEventListener('turbolinks:load', window.App.init);

// Re-initialize the Material Design Lite text fields and such after a
// turbolinks load.
// I think this will slowly memory-leak due to the fact that there is not
// an equivalent "downgradeDom" method.
document.addEventListener('turbolinks:load', function() {
  componentHandler.upgradeDom();
});
