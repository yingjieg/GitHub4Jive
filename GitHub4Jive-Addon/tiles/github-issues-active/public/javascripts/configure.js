/**
 * Created by glen.nicol on 8/19/14.
 */
$(function () {
    jive.tile.onOpen(function(config, options ) {

        $("#j-card-authentication").show();
        $("#j-card-configuration").hide();
        gadgets.window.adjustHeight();

        if(typeof config === "string"){
            config = JSON.parse(config);
            if(typeof config === "string"){
                config = JSON.parse(config);
            }
        }

        // prepopulate the sequence input dialog
        $("input[name=post_activity]").val([config["posting"]]);

        $(document).bind("github4jiveConfigDone",function () {
            var status = $("input[name=post_activity]:checked").val();
            var toReturn = {
                "posting"  : status

            };

            jive.tile.close(toReturn);
        });

    });

});