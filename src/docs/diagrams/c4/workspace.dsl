workspace "Name" "Description" {

    !identifiers hierarchical

    model {
        u = person "User" "Mobile"

        s3 = softwareSystem "S3" {
            tags "External"
        }

        onlineCinemas = softwareSystem "Online Cinemas" {
            tags "External"
        }

        recommendations = softwareSystem "Recommendations System" {
            tags "External"
        }

        payments = softwareSystem "Payments System" {
            tags "External"
        }

        ss = softwareSystem "Cinemaabyss System" {
            wa = container "Web Application" {
                tags "WebApp"
                description "Progressive Web Application\nResponsive for:\nMobile, Tablets, Laptops"
                technology "HTML, JS, CSS"
                !adrs /adrs/system
            }

            smartTV = container "SmartTV Application" {
                tags "SmartTV"
                description "A Native application: Android, tvOS, webOS etc"
                !adrs /adrs/system
            }

            apiGateway = container "API Gateway"  {
                tags "APIGateway"
                technology "NGINX"
                !adrs /adrs/container
            }

            group "Movies Microservice" {
                movies = container "Movies" {
                    tags "Microservice"
                    description "Movies metadata: genre, сast, rates"
                    technology "Go, REST, Kafka"
                    !adrs /adrs/system
                }

                moviesDB = container "Movies DB" {
                    tags "Database"
                    technology "Postgres"
                }
            }
            
            group "Users Microservice" {
                users = container "Users" {
                    tags "Microservice"
                    description "Users metadata: BIO, movies history etc"
                    technology "Go, REST, Kafka"
                }

                usersDB = container "Users DB" {
                    tags "Database"
                    technology "Postgres"
                }
            }

            group "Payments Microservice" {
                payments = container "Payments" {
                    tags "Microservice"
                    description "Processes payments"
                    technology "Go, REST, Kafka"
                }

                paymentsDB = container "Payments DB" {
                    tags "Database"
                    technology "Postgres"
                }
            }

            group "Subscriptions Microservice" {
                subscriptions = container "Subscriptions" {
                    tags "Microservice"
                    description "Handles subscriptions"
                    technology "Go, REST, Kafka"
                }

                subscriptionsDB = container "Subscriptions DB" {
                    tags "Database"
                    technology "Postgres"
                }
            }

            internalMessageBus = container "Message Bus" {
                tags "Bus"
                technology "Kafka"
            }

            recommendationsMessageBus = container "Recommendations Message Bus" {
                tags "Bus"
                technology "RabbitMQ"
            }
        }

        u -> ss.wa "Uses" "Web browser"
        u -> ss.smartTV "Uses" "Web browser, Native App"

        ss.smartTV -> ss.wa "Builds from PWA" "PWABuilder"

        ss.wa -> ss.apiGateway "Requests CRUD" "HTTPS, JSON" 

        ss.apiGateway -> ss.movies "Requests CRUD" "HTTPS, JSON"
        ss.apiGateway -> ss.users "Requests CRUD" "HTTPS, JSON"
        ss.apiGateway -> ss.payments "Requests CRUD" "HTTPS, JSON"
        ss.apiGateway -> ss.subscriptions "Requests CRUD" "HTTPS, JSON"

        ss.movies -> ss.moviesDB "SQL"
        ss.movies -> ss.internalMessageBus
        ss.movies -> onlineCinemas "Gets movies metadata"
        ss.movies -> s3 "Reads and writes movies media"
        ss.movies -> ss.recommendationsMessageBus "Provides movies collection"

        ss.users -> ss.recommendationsMessageBus "Provides Users interaction history"
        ss.users -> ss.internalMessageBus
        ss.users -> ss.usersDB "SQL"

        ss.payments -> ss.internalMessageBus
        ss.payments -> ss.paymentsDB "SQL"
        ss.payments -> payments "Executes payments"

        ss.subscriptions -> ss.internalMessageBus
        ss.subscriptions -> ss.subscriptionsDB "SQL"

        ss.recommendationsMessageBus -> recommendations "Reads and sends messages to"
    }

    views {
        systemContext ss "SystemDiagram" {
            include *
            autolayout lr
        }

        container ss "Containers" {
            include *
        }

        styles {
            element "Element" {
                color #0773af
                stroke #0773af
                strokeWidth 7
                shape roundedbox
            }
            element "Person" {
                shape person
            }
            element "Database" {
                shape cylinder
            }

            element "WebApp" {
                shape WebBrowser
            }

            element "SmartTV" {
                shape Window
            }

            element "Microservice" {
                shape Hexagon
            }

            element "Bus" {
                shape Pipe
            }

            element "Boundary" {
                strokeWidth 5
            }

            element "External" {
                stroke gray
            }

            relationship "Relationship" {
                thickness 4
            }
        }
    }

    configuration {
        scope softwaresystem
    }

}