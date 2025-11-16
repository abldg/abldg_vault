if [ X != X$(command -v docker) ]; then
  #---docker-ps---
  alias dkps='docker ps --format="table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}"'
  alias dkpsid='docker ps --format="{{.ID}}"'
  alias dkpsname='docker ps --format="{{.Names}}"'
  #alias dpsport='docker ps --format="table {{.ID}}\t{{.Names}}\t{{.Ports}}"'
  #---docker-images---
  alias dkimgs='docker images --format="table {{.Repository}}\t{{.Tag}}"'
  #---docker-compose---
  # alias dkc='docker compose'
  # alias dkcdw='docker compose down'
  # alias dkcdwv='docker compose down --volumes'
  # alias dkcupd='docker compose up -d'
  # alias dkcps='docker compose ps'

  #---docker-others---
  alias dksystemprunea='yes | docker system prune -a'
  alias dkexec='docker exec -it'
  alias dklog='docker logs -f'
  alias dknls='docker network ls'
  alias dkvls='docker volume ls'
  alias dkcls='docker compose ls'
fi
