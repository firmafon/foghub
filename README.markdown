Foghub is a small tool to associate git commits (on Github) with cases in Fogbugz and ask for codereviews.

The code is under development if you have features requests then ping me at ns@firmafon.dk.

Why do code reviews?
====================

[Simply read this blogpost](http://www.codinghorror.com/blog/2006/01/code-reviews-just-do-it.html).

Feature plans
=============

Associate commit with case: 

    git commit -am "This is a commit #65"

This will post a comment to case 65 on Fogbugz with the commitmassage and a link to the commit on Github.

Ask for codereview:

    git commit -am "This is a commit that needs review #review @user"

This will add a new case in Fogbugz in the category "code review" and assign it to the user.

Ask for codereview and associate with case:

    git commit -am "This commit to case #65 needs #review by @user"

This will add a new case in Fogbugz in the category "code review" and assign it to the user but will also post a comment to case 65 in Fogbugz with the commitmassage and a link to the commit on Github.

And commits can be associatet with more then one case:

    git commit -am "This commit is closing case #65 and #66"

This will post a comment to both case 65 and 66 on Fogbugz with the commitmassage and a link to the commit on Github.
  
If you commit whitout ref to a user it will automaticly make a new case, but it dosent asign it.