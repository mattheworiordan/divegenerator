function generate_dives()
{
	var originaltext = $('#generate_dives_button').val(); // get the button text
	
	// hide dive results and show user we are now loading
	$('#diveresult').css("display", "none");
	$('#generate_dives_button').val("Loading...");
	
	// check that all params have valid selections and build up params to pass through on JSON request to app
	paramdic = {'post[discipline]':'Discipline','post[jumps]':'Jumps','post[sequence]':'Dive sequence'};
	JSONparams = {};
	for (field in paramdic) {
		JSONparams[field] = $("input[name='" + field + "']:checked").val();
		if (!JSONparams[field]) {
			alert ('Please select an option for "' + paramdic[field] + '"');
			return;
		}
	}
	
	// send request
	$.getJSON("/shortest_path.json", JSONparams, function(data, textStatus) {
	  	if (textStatus != "success" || !data.success) {
			alert ("Unfortunately your dives could not be generated: \n" + data.message + "\nServer response: " + textStatus)
		} else {
			// clear out old dive pool
			(dp = $('#divepool')).empty();
			var sequence = 1;
			for (jump in data.data) {
				var moveSymbol = [];
				for (move in data.data[jump])
					 moveSymbol.push (data.data[jump][move][2])
				dp.append ("<div class='dive'><div class='number'>" + sequence++ + ". </div><div class='sequence'>" + moveSymbol.join(' - ') + "</div></div>");
			}
		}
		$('#diveresult').css("display", "block");
		$('#generate_dives_button').val(originaltext);
	});
}

var jump_max = 40, jump_all_text;

function review_jump_numbers()
{
	jump_field = $("input[name='post[jumps]']:last");
	
	// if the user has selected random, then the all option is not relevant so offer 40 jumps
	if ($(this).val() == "random")
	{
		if (jump_field.val() == "all") {
			jump_field.val('40');
			jump_all_text = $("label[for='" + jump_field.attr("id") + "']").text()
			$("label[for='" + jump_field.attr("id") + "']").text ("40");
		}
			
	} else 
	{
		if (jump_field.val() != "all") {
			jump_field.val('all');
			$("label[for='" + jump_field.attr("id") + "']").text(jump_all_text);
		}
	}
}

$(document).ready(function(){
	$.sifr({
		path: '/fonts/',
		save: true,
		version: 2
	});
	$('h1').sifr({ font: 'sansbetween' });
	
	$('#generate_dives_button').click(generate_dives);
	$("input[name='post[sequence]']").click(review_jump_numbers);
	$("input[name='post[sequence]']:checked").click();
});



