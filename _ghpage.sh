## You need to set up github pages first,, make it load master/docs
## Use this only when you are in master branch

npm run build

rm -rf docs

mv dist docs

cp src/assets/404.html docs/404.html

sed -i -e 's/\<\/head\>/\<base href\=\"https:\/\/chekt.github.io\/github-project-manager\/\"\>\<\/head\>/g'  docs/index.html
sed -i -e 's/src\=\//src\=/g'  docs/index.html
sed -i -e 's/href\=\//href\=/g'  docs/index.html

rm docs/index.html-e

git add .

git commit -a -m "github pages update"

git push

echo "https://chekt.github.io/github-project-manager/"