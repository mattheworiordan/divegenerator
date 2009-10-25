function generate_dives()
{
	var originaltext = $('#generate_dives_button').val();
	$('#diveresult').css("display", "none");
	$('#generate_dives_button').val("Loading...");
	
	url = "/shortest_path.html";
	paramarr = ['post[discipline]','post[jumps]','post[sequence]'];
	params = {};
	for (param in paramarr)
	{
		params[paramarr[param]] = $("input[name='" + paramarr[param] + "']:checked").val();
	}
	$.getJSON(url, params, function(data) {
	  	if (!data.success) {
			alert ("Your dives could not be generated: \n" + data.message)
		} else {
			(dp = $('#divepool')).empty();
			var sequence = 1;
			for (jump in data.data) 
			{
				var moveSymbol = [];
				for (move in data.data[jump])
				{
					 moveSymbol.push (data.data[jump][move][2])
				}
				dp.append ("<div class='dive'><div class='number'>" + sequence++ + "</div><div class='sequence'>" + moveSymbol.join('-') + "</div></div>");
			}
		}
		$('#diveresult').css("display", "block");
		$('#generate_dives_button').val(originaltext);
	});

}

$(document).ready(function(){
	$.sifr({
		path: '/fonts/',
		save: true,
		version: 2
	});
	$('h1').sifr({ font: 'sansbetween' });
	
	$('#generate_dives_button').click(generate_dives);
});

