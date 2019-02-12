<script type="text/javascript">
document.addEventListener(&quot;DOMContentLoaded&quot;, function (event) {
    document.addEventListener(&quot;DOMContentLoaded&quot;, function (event) {
        SP.SOD.executeFunc(&apos;sp.js&apos;, &apos;SP.ClientContext&apos;, function () {
            var ctx = SP.ClientContext.get_current();
            var web = ctx.get_web();
            ctx.load(web);
            var currentUser = web.get_currentUser();
            currentUser.retrieve();
            var admin = currentUser.get_isSiteAdmin();
            admin.load();
            if (currentUser.get_isSiteAdmin() === false) {
                window.location.replace(&quot;/_layouts/15/AccessDenied.aspx&quot;);
                console.log(&quot;Redirect successful.&quot;);
                }
            }
        ); 
    });
});
</script>