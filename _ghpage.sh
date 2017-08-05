## You need to set up github pages first,, make it load master/docs
## Use this only when you are in master branch

npm run build

mv dist docs

cp src/assets/404.html docs/404.html

sed -i -e 's/\<\/head\>/\<base href\=\"https:\/\/chekt.github.io\/github-project-manager\/\"\>\<\/head\>/g'  dist/index.html
sed -i -e 's/src\=\//src\=/g'  dist/index.html

rm dist/index.html-e

git add .

git commit -a -m "github pages update"

git push

echo "https://chekt.github.io/github-project-manager/"