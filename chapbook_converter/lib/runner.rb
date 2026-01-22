
KILL_SERVER = "ps | grep -i SimpleHTTPServer | grep -i python | sed 's/^ *//' | cut -f 1 -d ' ' | xargs kill"

BODY = %Q{
echo "::: killing any stale instances"
#{KILL_SERVER}

echo "::: removing old code"
rm $CS_INSTALL/web/mygame/scenes/*
cp $PROJECT/* $CS_INSTALL/web/mygame/scenes

cp $PROJECT/*.png $CS_INSTALL/web/mygame
cp $PROJECT/*.jpg $CS_INSTALL/web/mygame
cp $PROJECT/*.ogg $CS_INSTALL/web/mygame

cd $CS_INSTALL
python3 -m http.server &

echo "::: launching game"
open http://localhost:8000/web/mygame/index.html

echo "::: running tests"
open http://localhost:8000/randomtest.html
open http://localhost:8000/quicktest.html

read -n1 -r -p "Press any key to exit SimpleHTTPServer..." key
 
#{KILL_SERVER}
}

class Runner

	def initialize(project_path, cs_install_path)
		@project_path = project_path.split('/')[-1]
		@cs_install_path = cs_install_path
	end

	def to_bash_script
		header = [ "#! /bin/bash\n",
		           "CS_INSTALL=\"#{@cs_install_path}\"",
		           "PROJECT=\"#{@project_path}\""
		          ]
		
		(header + [BODY]).join "\n"
	end

end

