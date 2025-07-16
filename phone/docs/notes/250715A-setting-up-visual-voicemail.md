Visual voicemail (VVM) in the stock phone app is not working.

I hold down 1 to quick-dial the voicemail service and set up voicemail.
Still not working.

I download Google Play Services and Phone by Google.
VVM tab in Phone app disappears when clicked.

After searching, I see that many people cannot set up VVM when using T-Mobile.
I'm using Mint, which is on the T-Mobile network.

https://discuss.grapheneos.org/d/11314-t-mobile-visual-voicemail
https://github.com/GrapheneOS/os-issue-tracker/issues/1951

Someone in the issue had a potential solution,
pulled from a thread in r/mintmobile.

https://github.com/GrapheneOS/os-issue-tracker/issues/1951#issuecomment-2730400654
https://www.reddit.com/r/mintmobile/comments/wm1ynh/mint_mobile_faq_updated/

1. Open GrapheneOS stock phone app
2. Disable VVM: `... > Settings > Voicemail > Visual voicemail > toggle off`
3. Reboot phone
4. Disable Wi-Fi
5. Open phone app and make sure VVM is still disabled
6. Get voicemail number: `... > Settings > Voicemail > Advanced Settings > Setup > Voicemail number`
7. Go to call forwarding menu: `... > Settings > Calling accounts > Mint Mobile > Call forwarding`
8. Set `When busy`, `When unanswered`, and `When unreachable` to the voicemail number
   - Leave `Always forward` off, or no one will be able to call you!
9. Wait 5 minutes
10. Re-enable VVM
11. Test it by having someone call and go to voicemail
12. Re-enable Wi-Fi

