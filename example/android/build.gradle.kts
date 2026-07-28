allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix: Resolve "Inconsistent JVM Target Compatibility" in photo_manager,
// which mixes Java 17 and Kotlin 21 targets. Scoped to only that plugin.
subprojects {
    if (project.name == "photo_manager") {
        val configureAction = Action<Project> {
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = "17"
                targetCompatibility = "17"
            }
        }

        if (state.executed) {
            configureAction.execute(this)
        } else {
            afterEvaluate(configureAction)
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
