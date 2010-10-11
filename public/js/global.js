$(function() {

  var page = 2;
  $('.load-more a').click(function() {
    var $this = $(this);
    if ($this.is('.throbber')) { return false; }
    $this.addClass('throbber').html("<span>Loading…</span>")
    $.ajax({
      type : "GET",
      url : $(this).attr("href"),
      data : { page : page },
      dataType : 'json',
      success : function(data) {
        if (data.pagination.next_page) { page = data.pagination.next_page }
        else { $this.parent().remove() }

        $('#tweets').append(data.html);
        $this.removeClass('throbber').html("<span>Load more…</span>")
      }
    })
    return false;
  })

})
