(function (root, factory) {
    if (root === undefined && window !== undefined) root = window;
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module unless amdModuleId is set
        define(["jquery"], function (a0) {
            return (factory(a0));
        });
    } else if (typeof module === 'object' && module.exports) {
        // Node. Does not work with strict CommonJS, but
        // only CommonJS-like environments that support module.exports,
        // like Node.
        module.exports = factory(require("jquery"));
    } else {
        factory(root["jQuery"]);
    }
}(this, function (jQuery) {

    (function ($) {
        $.fn.selectpicker.defaults = {
            noneSelectedText: 'Сонгох',
            noneResultsText: '{0} олдсонгүй',
            countSelectedText: function (numSelected, numTotal) {
                return '{0} ширхэг сонгогдсон';
            },
            maxOptionsText: function (numAll, numGroup) {
                return [
                    (numAll == 1) ? 'Limit reached ({n} item max)' : 'Limit reached ({n} items max)',
                    (numGroup == 1) ? 'Group limit reached ({n} item max)' : 'Group limit reached ({n} items max)'
                ];
            },
            selectAllText: 'Бүгдийг сонгох',
            deselectAllText: 'Сонголтыг арилгах',
            multipleSeparator: ', '
        };
    })(jQuery);


}));