var datepicker = $.fn.datepicker.noConflict(); // return $.fn.datepicker to previously assigned value
$.fn.bootstrapDP = datepicker;
$.fn.bootstrapDP.dates['mn'] = {
    "format": "yyyy-mm-dd",
    "days": ["Ням", "Даваа", "Мягмар", "Лхагва", "Пүрэв", "Баасан", "Бямба"],
    "daysShort": ["Ням", "Дав", "Мяг", "Лха", "Пүр", "Баа", "Бям"],
    "daysMin": ["Ня", "Да", "Мя", "Лх", "Пү", "Ба", "Бя"],
    "months": ["1-р сар", "2-р сар", "3-р сар", "4-р сар", "5-р сар", "6-р сар", "7-р сар", "8-р сар", "9-р сар", "10-р сар", "11-р сар", "12-р сар"],
    "monthsShort": ["1сар", "2сар", "3сар", "4сар", "5сар", "6сар", "7сар", "8сар", "9сар", "10сар", "11сар", "12сар"],
    "weekStart": 1
};
$.fn.bootstrapDP.defaults.language = "mn";

// // using date time picker
// $.fn.datetimepicker.dates['mn'] = {
//     days: ["Ням", "Даваа", "Мягмар", "Лхагва", "Пүрэв", "Баасан", "Бямба", "Ням"],
//     daysShort: ["Ням", "Дав", "Мяг", "Лха", "Пүр", "Баа", "Бям", "Ням"],
//     daysMin: ["Ня", "Да", "Мя", "Лх", "Пү", "Ба", "Бя", "Ня"],
//     months: ["1-р сар", "2-р сар", "3-р сар", "4-р сар", "5-р сар", "6-р сар", "7-р сар", "8-р сар", "9-р сар", "10-р сар", "11-р сар", "12-р сар"],
//     monthsShort: ["1сар", "2сар", "3сар", "4сар", "5сар", "6сар", "7сар", "8сар", "9сар", "10сар", "11сар", "12сар"],
//     today: "Өнөөдөр"
// };
// $.fn.datetimepicker.defaults.language = "mn";

function getDecimalPay(numval) {
    numval = numval + "";
    var cde = 1, vv = "";
    for (var i = 0; i < numval.length; i++) {
        if (numval.charAt(i) != "'")vv += numval.charAt(i);
    }
    numval = vv;
    vv = "";

    for (i = numval.length - 1; i >= 0; i--) {
        if (i != 0 && cde == 3) {
            vv += numval.charAt(i) + "'";
            cde = 1
        } else {
            vv += numval.charAt(i);
            cde++;
        }
    }
    numval = "";
    for (var i = vv.length - 1; i >= 0; i--) {
        numval += vv.charAt(i);
    }
    return numval;
}

function valid_id(id) {
    return id !== undefined && id !== null && id !== ""
}