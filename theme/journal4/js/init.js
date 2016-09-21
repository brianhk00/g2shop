(function () {
    /* get scroll width */
    var $outer = $('<div>').css({visibility: 'hidden', width: 100, overflow: 'scroll'}).appendTo('body'),
        widthWithScroll = $('<div>').css({width: '100%'}).appendTo($outer).outerWidth();
    $outer.remove();
    var scrollWidth = 100 - widthWithScroll;

    var last = null, current = null;

    if ($('html').hasClass('responsive-layout')) {
        /* add resize event */
        $(window).resize(function () {
            var width = $(window).width() + scrollWidth;
            if (width <= 760) {
                current = 'mobile';
            } else if (width <= 980) {
                current = 'tablet';
            } else {
                current = 'desktop';
            }
            if (last !== current) {
                last = current;
                switch (current) {
                case 'mobile':
                    Journal.onMobile();
                    break;
                case 'tablet':
                    Journal.onTablet();
                    break;
                case 'desktop':
                    Journal.onDesktop();
                    break;
                }
            }
        });
    } else {
        Journal.onDesktop();
    }
}());

(function () {
    var t = null;
    $(window).resize(function () {
        clearTimeout(t);
        t = setTimeout(function () {
            //$('.mega-menu').width($('#header').width());
            $('.drop-down > ul a').unbind('mouseenter').mouseenter(function () {
                var $current = $(this).parent();
                var $next = $('>ul', $current);
                if ($next.length) {
                    if (!$current.hasClass('left') && $current.width() + $next.offset().left > $(window).width()) {
                        $current.addClass('left');
                    }
                }
            });
            $('#cart').removeClass('active');
            $('.mobile-trigger').removeClass('menu-open');
            Journal.itemsEqualHeight();
        }, 300);
    });
}());

$(window).load(function() {
    $("img.lazy").lazy({
        bind: 'event',
        visibleOnly: false,
        effect: "fadeIn",
        effectTime: 250
    });
});

(function () {
    var $menu = $('.android.tablet .super-menu > li > a');
    if ($menu.length) {
        $menu.click(function (e) {
            $menu.not(this).removeClass("clicked");
            $(this).toggleClass("clicked");
            if ($(this).hasClass("clicked")) {
                event.preventDefault();
            }
        });
    }

    $('.mobile-menu a:not([href]), .mobile-menu a[href="javascript:;"]').live('click', function () {
        $(this).parent().find('> .mobile-plus').trigger('click');
    });

    $('.modal').appendTo($('body'));
}());

