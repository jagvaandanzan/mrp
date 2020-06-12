function sendFile(file, toSummernote) {
    let data = new FormData;
    data.append('upload[image]', file);
    return $.ajax({
        data: data,
        type: 'POST',
        url: '/user/uploads',
        cache: false,
        contentType: false,
        processData: false,
        success: function (data) {
            return toSummernote.summernote("insertImage", data.url);
        }
    });
}

$(document).ready(function () {
    $('[data-provider="summernote"]').each(function () {
        return $(this).summernote({
            lang: 'mn-MN',
            height: 300,
            codemirror: {
                lineWrapping: true,
                lineNumbers: true,
                tabSize: 2,
                theme: 'solarized'
            },
            toolbar: [
                ["style", ["style"]],
                ["style", ["bold", "italic", "underline", "clear"]],
                ["fontsize", ["fontsize"]],
                ["color", ["color"]],
                ["para", ["ul", "ol", "paragraph"]],
                ["height", ["height"]],
                ["table", ["table"]],
                ['insert', ['picture', 'link', 'hr']]
            ],
            callbacks: {
                onImageUpload: function (files) {
                    return sendFile(files[0], $(this));
                }
            }
        });
    });
});