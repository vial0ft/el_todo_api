#===========
#Build Stage
#===========
FROM elixir:1.14.0-alpine as build

#Copy the source folder into the Docker image
COPY . .

#Install dependencies and build Release
RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix local.rebar --force && \
    mix local.hex --force && \
    mix deps.get && \
    mix release

#Extract Release archive to /rel for copying in next stage    
RUN APP_NAME="el_todo_api" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME` && \
    mkdir /export && \
    cp -R $RELEASE_DIR /export
    
#================
#Deployment Stage
#================

FROM elixir:1.14.0-alpine


#Set environment variables and expose port
EXPOSE 4000
ENV REPLACE_OS_VARS=true \
    SECRET_KEY_BASE=1 \
    PHX_SERVER=true \
    PORT=4000

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ .

#Set default entrypoint and command
CMD ["/el_todo_api/bin/el_todo_api", "start"]
