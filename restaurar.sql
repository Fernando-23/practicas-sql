use master
go
restore database GDD
from disk = '' --aca deberias de poner tu path del .bak
with replace

use GDD
go