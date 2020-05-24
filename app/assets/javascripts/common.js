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