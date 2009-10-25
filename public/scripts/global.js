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

function review_discipline()
{
	$("input[name='post[sequence]']").removeAttr ("disabled");
	$("div.column#sequence").removeClass ("disabled");
	$("input[name='post[sequence]']:checked").click();
}

function review_jump_numbers()
{
	// now that we have selected dive sequence, enable jumps section
	$("input[name='post[jumps]']").removeAttr ("disabled");
	$("div.column#jumps").removeClass ("disabled");
	
	if ($(this).val() == "random") 	// if the user has selected random, then the all option is not relevant so offer 40 jumps
	{
		$("input[name='post[jumps]']").removeAttr ("disabled");
		$("div.column#jumps label").removeClass ("disabled")
		
		jump_field.val('40');
		$("label[for='" + jump_field.attr("id") + "']").text ("40");
			
	} else { // user has selected shortest route 
		// disable all options other than ALL
		$("input[name='post[jumps]']").attr ("disabled","true");
		$("div.column#jumps label").addClass ("disabled")
		
		// set the ALL option to all
		jump_field.removeAttr ("disabled");
		jump_field.val('all');
		
		// set the text and enable the label for ALL option
		$("label[for='" + jump_field.attr("id") + "']").text (jump_all_text);
		$("label[for='" + jump_field.attr("id") + "']").removeClass ("disabled");
		jump_field.attr ("checked", "true");
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
	$("input[name='post[discipline]']").click(review_discipline);
	$("input[name='post[sequence]']").click(review_jump_numbers);
	
	jump_field = $("input[name='post[jumps]']:last");
	jump_all_text = $("label[for='" + jump_field.attr("id") + "']").text(); // get the text used to describe all from the app
	
	$("input[name='post[discipline]']:checked").click();
});



