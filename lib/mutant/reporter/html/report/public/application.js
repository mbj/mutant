
$(document).ready(function(){
	// show/hide subjects per each scope on mouse over
	$(".scope").hover(
	  function() {
	    $(this).find("div.subject").show();
	  },
	  function() {
		$(this).find("div.subject").hide();
	  }
	);
});