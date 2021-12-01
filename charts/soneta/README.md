# Soneta Kubernetes Helm Chart

Funkcjonalność zawarta w tym repozytorium jest w fazie ***beta*** i może być przedmiotem zmian. Funkcjonalność ***beta*** nie podlega gwarancji.

## Użycie
Instalacja aplikacji: „enova” to jej nazwa, „soneta/soneta” to odpowiednio repozytorium/nazwa_chart’a

```console
helm install enova soneta/soneta
```
## Parametryzacja
### Parametyzacja poprzez *--set*
Podczas instalacji poleceniem *helm install* lub aktualizacji *helm upgrade* można parametryzować aplikacje za pomocą *--set*. \
Poniżej parametry do wykorzystania podczas instalacji z przykładowymi wartościami:
```
--set image.repository="" - wybór repozytorium dla obrazu docker'owego
--set image.tag="2110.2.5" - wybór konkretnego taga określający wersję obrazu docker'owego
--set-file listaBazDanych=enova.xml - wczytanie pliku listy baz danych
--set ingress.enabled=true - włączenie/wyłączenie zasobu Ingress
--set resources.afs.enabled=true - włączenie/wyłączenie Azure File Storage
--set resources.afs.accountName="login" - login do Azure File Storage
--set resources.afs.accountKey="klucz" - klucz do Azure File Storage
--set resources.afs.shareName="enova"  - nazwa File Share
--set envs.server[0].name="AzureFileShare.DefaultFolder" - nazwa montowanego zasobu
--set envs.server[0].value="Z:" - litera montowanego dysku
--set envs.web[0].name="WEBSettings.adminPwd" - nazwa potrzebna do nadania hasła administratora do serwera web
--set envs.web[0].value="test" - hasło do serwera web
--set image.scheduler=true - włączenie/wyłączenie harmonogramu zadań
--set resources.web.requests.cpu=100m - ustawienie requestu 100m na serwerze web
--set resources.server.limits.memory=3Gi - ustawienie limitu 3Gi na serwerze biznesowym
--set resources.web.limits.memory=2Gi - ustawienie limitu 2Gi na serwerze web
--set image.webTagPostfix="-core" - włączenie serwera web w wersji .netcore
```
### Parametryzacja plikiem *values.yaml*
Analogicznie te same parametry moga być umieszczone w pliku values. Plik jest przekazywany do *helm install* lub *helm upgrade* z flagą _–f_ lub _-values_:
```
envs:
  server:
  - name: AzureFileShare.DefaultFolder
    value: 'Z:'
  web: 
  - name: ProductSettings__Settings__AdminPwd
    value: "test"
image:
  repository: ""
  tag: 2110.2.5
  webapi: false
  scheduler: false
  webTagPostfix: "-core"
ingress:
  enabled: true
resources:
  afs:
    accountName: login
    accountKey: klucz
    enabled: true
    shareName: enova
  web:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 50m
      memory: 384Mi
  server:
    limits:
      cpu: 1
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 384Mi
```

## Zawartość paczki

Po utworzeniu nowego Chart’a lub wykorzystaniu gotowej paczki Soneta dostępne będą katalogi i pliki .yaml niezbędne do uruchomienia aplikacji w klastrze Kubernetes
### Chart.yaml
Plik Chart zawiera jego opis np. nazwę oraz wersję. Nie jest wykorzystywany do parametryzowania aplikacji

### Helmignore
Lista plików/folderów ignorowanych podczas budowania paczki np. test.txt, my-folder

### Values.yaml 
Jest zbiorem wartości, które będą zaimplementowane do Chart’a. Za pomocą tego pliku można określić np. z jakimi zasobami sprzętowymi zostanie uruchomiona skonteneryzowana aplikacja lub jej poszczególne POD’y, sparametryzować obsługę dodatkowego dysku do wymiany danych, czy ustawić przełączniki do uruchamiania poszczególnych POD’ów.
Zawartość pliku values.yaml może pochodzić z kilku źródeł: \
\
•	Nadrzędny plik wartości „wstrzykiwanych” do Chart’a – w tym przypadku podczas instalacji lub aktualizacji wszystkie wartości wsadowe dla aplikacji pobierane z głównego katalogu Charta: 
```console
helm install enova soneta/soneta 
```
\
•	Jest przekazywany do helm install lub helm upgrade z flagą _–f_ lub _-values_ : 
```console
helm install enova soneta/soneta –values .\values
```
Rozwiązanie to pozwala na użycie osobnego pliku values np. do parametryzowania poszczególnych instancji aplikacji. W takim przypadku dane 
w pierwszej kolejności pobierane są ze wskazanego pliku values, pozostałe dane (o ile takie są) pobierane są z głównego katalogu Chart’a. Można więc w głównym pliku trzymać dane niezmienne, a dodatkowo parametryzować poszczególne instancje dodatkowym plikiem, który przekazywany jest do helm install lub helm upgrade. \
\
•	Poszczególne parametry przekazywane jako _--set_:
```console 
helm install enova soneta\soneta --set resources.server.limits.memory=2Gi
```
Na tym przykładzie ustawiony został limit pamięci dla serwera biznesowego na 2Gi. Wartości podczas instalacji lub aktualizacji wczytują się w następującej kolejności:  parametr _--set_, values z flagą _–f_ lub _-values_, values z głównego katalogu Chart’a. 
##	Templates
Templates jest podkatalogiem paczki Helm, z opisami zasobów wgrywanych na Kubernetes.

###	Configmap.yaml
ConfigMap to obiekt interfejsu API używany do przechowywania niepoufnych danych w parach klucz-wartość. służy do ustawiania danych konfiguracyjnych niezależnie od kodu aplikacji. ConfigMap umożliwia oddzielenie konfiguracji specyficznej dla środowiska od obrazów kontenerów, dzięki czemu aplikacje można łatwo przenosić. Przykładowo w enova365 jest on używany do połączenia instancji aplikacji z właściwą bazą danych. 

###	 Secret.yaml
Umożliwia przechowywanie poufnych informacji, takich jak hasła, tokeny i klucze ssh, klucze prywatne i zarządzanie nimi. Przechowywanie poufnych informacji w Secret jest bezpieczniejsze i bardziej elastyczne niż umieszczanie ich dosłownie w definicji Poda lub w obrazie kontenera. Użycie klucza tajnego oznacza, że nie trzeba zawierać poufnych danych w kodzie aplikacji.

###	Deployment.yaml
Informuje on Kubernetes, jak tworzyć i aktualizować instancje aplikacji. Po stworzeniu Deploymentu węzeł master Kubernetesa zleca uruchomienie tej aplikacji na indywidualnych węzłach klastra. Deployment dodatkowo dba o scenariusze aktualizacji podów, jeżeli wprowadzone zostaną zmiany np. nowa wersja obrazów. W środowisku enova365 rozróżniamy 4 deploymenty: \
•	deployment-server – POD serwera biznesowego \
•	deployment-web – POD serwera Web \
•	deployment-webapi – POD do komunikacji z webapi \
•	deployment-scheduler – POD harmonogramu zadań
