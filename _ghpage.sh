## You need to set up github pages first,, make it load master/docs
## Use this only when you are in master branch

npm run build

mv dist docs

# mv docs/assets/404.html docs/404.html

# rmdir docs/assets

git add .

git commit -a -m "github pages update"

git push

echo "https://chekt.github.io/github-project-manager/"