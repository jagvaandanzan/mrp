function load_image_preview(last_tr) {
    $(last_tr + ' .preview').on('click', function () {
        $(this).parent().find('input').click();
    });
    $(last_tr + ' input.image-file').on('change', function () {
        readURL(this, $(this).parent().parent().find('.preview:first'));
    });
}

function readURL(input, div) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            div.html("<img class='preview-img' src='" + e.target.result + "'>");
        };
        reader.readAsDataURL(input.files[0]);
    }
}

$(function () {
    $('[data-toggle="tooltip"]').tooltip();

    $('button#download-excel').on('click', function () {
        $(this).attr('disabled', 'disabled');
        var f = $('#search-form');
        var act = f.attr('action');
        f.attr('action', act + '.xlsx');
        f.submit();
        f.attr('action', act);
        setTimeout(reset_excel_download_btn, 3000);
    });
});

function reset_excel_download_btn() {
    $('button#download-excel').removeAttr('disabled');
}

function get_name_text(n, v) {
    if (v !== undefined && v.length > 0) {
        if (n.length > 0) n += ", ";
        n += v;
    }
    return n;
}