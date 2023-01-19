mkdir -p "Lessons"
mkdir -p "Templates"
mkdir -p "WorkshopTests"
mkdir -p "WorkshopDeployments"

# Move to the lessons directory
cd Lessons
# Get all the lessons TODO: In the future we may want to separate these into novice, intermediate, e.t.c..

# define the full set of lessons
REPOLIST=(
"r-novice"
"git-novice"
"python-novice"
"shell-novice"
"project-novice"
"spreadsheets"
"openrefine-data-cleaning"
"project-intermediate"
)

# loop over the lessons clone/pull, add template if needed, and fetch on all branches.
for REPONAME in "${REPOLIST[@]}";
do
  # clone the repo if it is absent else pull from the remote
  git clone "git@github.com:Southampton-RSG-Training/${REPONAME}.git" || (git -C "$REPONAME" pull)
  # add the template
  git -C "$REPONAME" remote add template "git@github.com:Southampton-RSG-Training/lesson-template.git" || echo "Template already exists"
  git -C "$REPONAME" fetch --all
done

# go back to ~/TrainingProjects (or wherever you put TrainingProjects)
cd ..

cd Templates
# define the full set of templating documentation
REPOLIST=(
"lesson-template"
"workshop-template"
"rsg-theme"
"setup-documents"
)

# loop over the templates clone/pull, .
for REPONAME in "${REPOLIST[@]}";
do
  # clone the repo if it is absent else pull from the remote
  git clone "git@github.com:Southampton-RSG-Training/${REPONAME}.git" || (git -C "$REPONAME" pull)
done

# go back to ~/TrainingProjects (or wherever you put TrainingProjects)
cd ..

cd WorkshopTests
# define the full set of templating documentation
REPOLIST=(
"SWC-Course-Demo"
"SWC-Demo"
"DC-Demo"
)

# # loop over the workshop tests clone/pull, add template if needed, and fetch on all branches.
for REPONAME in "${REPOLIST[@]}";
do
  # clone the repo if it is absent else pull from the remote
  git clone "git@github.com:Southampton-RSG-Training/${REPONAME}.git" || (git -C "$REPONAME" pull)
  # add the template
  git -C "$REPONAME" remote add template "git@github.com:Southampton-RSG-Training/workshop-template.git" || echo "Template already exists"
  git -C "$REPONAME" fetch --all
done


# go back to ~/TrainingProjects (or wherever you put TrainingProjects)
cd ..

cd WorkshopDeployments
# define any deployed workshops that need debugging
REPOLIST=(
"Doctoral-College-03-23"
)

# # loop over the workshop tests clone/pull, add template if needed, and fetch on all branches.
for REPONAME in "${REPOLIST[@]}";
do
  # clone the repo if it is absent else pull from the remote
  git clone "git@github.com:SRSG-Workshops/${REPONAME}.git" || (git -C "$REPONAME" pull)
  # Template will have already been attached so just fetch all
  git -C "$REPONAME" fetch --all
done