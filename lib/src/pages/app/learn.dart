import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;

import 'package:aegistree/src/pages/app/detailed_diseases.dart';
import 'package:aegistree/src/src.dart';

class Learn extends ConsumerWidget {
  const Learn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultShadow = BoxShadow(
      color: Colors.black.withOpacity(.25),
      blurRadius: 4,
      offset: const Offset(0, 4),
    );

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      color: black60,
                    )
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Koho(
                            "Discover how to identify and treat these diseases to keep your trees thriving!",
                            fontWeight: FontWeight.w600,
                            color: black60,
                          ),
                        ),
                        Transform.flip(
                          flipX: true,
                          child: SizedBox(
                            width: 100,
                            child: Image.asset(
                              'assets/images/plant-hand.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(32),
              InknutAntiqua(
                "Types of Leaf Diseases",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                shadow: [defaultShadow],
              ),
              const Gap(16),
              FutureBuilder(
                future: fetchDiseases(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    final diseases = snapshot.data as List<LearnEntity>;
                    return Expanded(
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: diseases.length,
                        itemBuilder: (context, index) {
                          final disease = diseases[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return DetailedDiseases(disease);
                                }),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFFFE9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [defaultShadow],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 22,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: Image.memory(
                                            disease.disease.image)),
                                    const Gap(12),
                                    Koho(
                                      disease.disease.name,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF247408),
                                      textAlign: TextAlign.center,
                                      shadow: [defaultShadow],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<LearnEntity>> fetchDiseases() async {
    final diseaseTypes = [
      "Anthracnose",
      "Black spot",
      "Bacterial Leaf Blight",
      "Canker",
      "Downy mildew",
      "Powdery mildew",
      "Rust",
      "Shot hole",
      "Leaf spot",
      "Sooty mold",
    ];

    // Use Future.wait to handle multiple async operations
    final diseases = await Future.wait(
      diseaseTypes.map((type) async {
        final id = uuid.v4();
        final response =
            await http.get(Uri.parse("https://robohash.org/$id.png/?set=set4"));

        if (response.statusCode != 200) {
          throw Exception('Failed to load image for $type');
        }

        return DiseaseEntity(
          id: id,
          name: type,
          description: "This is a description of $type",
          image: response.bodyBytes, // Use bodyBytes to get Uint8List
          createdAt: DateTime.now(),
          createdBy: "secret", imagePath: '',
        );
      }),
    );

    final learn = [
      LearnEntity(
        disease: diseases[0],
        description:
            "Anthracnose is a term used to loosely describe a group of related fungal diseases that typically cause dark lesions on leaves. In severe cases it may also cause sunken lesions and cankers on twigs and stems. ",
        symptoms:
            "Tan to brown irregularly shaped spots or blotches on young leaves. Infected leaves are often distorted, cupped or curled. Severe infection can result in leaf drop in spring. Trees produce a second growth of leaves by midsummer if leaf drop occurs. Anthracnose may cause tan to dark brown spots on mature leaves but these leaves do not become cupped or distorted. Leaf spots on mature leaves are often found with minor wounds like insect feeding. Leaf symptoms are often most severe on the lower and inner branches of the tree but may progress up through the canopy.",
        treatment:
            "To manage anthracnose leaf disease, practice good sanitation by removing infected leaves and debris, ensure proper plant spacing for air circulation, and water plants at the base in the morning to keep foliage dry. Apply fungicides like chlorothalonil or azoxystrobin as needed, and consider using disease-resistant plant varieties. Improving soil drainage and health can also help plants resist infection. Regularly monitor for early signs of the disease to enable prompt intervention. For persistent issues, consult a local agricultural extension office or plant pathologist.",
      ),
      LearnEntity(
        disease: diseases[1],
        description:
            "Black spot is the blemish that results from a bacterial or fungal infection that can grow on any type of plant, though it particularly affects fleshy-leaved plants, like roses. It commonly develops in the hot and humid conditions at the beginning of the growing season.",
        symptoms:
            "Black spot lesions (i.e., infected areas) are roughly circular and may be up to ½ inch in diameter.  Lesions often have feathery margins and are dark brown to black in color.  Black spot initially appears during periods of wet weather, particularly when rose leaves are first emerging.  The disease starts on lower leaves but will spread to the entire plant.",
        treatment:
            "Black spot disease is best managed through preventative measures that reduce the likelihood of initial infection rather than relying on curative treatments. Effective strategies include planting disease-free seeds, rotating crops, and pruning trees or vines to enhance air circulation while removing diseased parts. Maintaining good orchard hygiene—such as sterilizing pruning tools and removing infected fruit—and clearing infected leaf litter and plant material are crucial. Additionally, applying preventative sprays can help protect crops from black spot disease.",
      ),
      LearnEntity(
        disease: diseases[2],
        description:
            "Bacterial leaf blight is a plant disease caused by bacteria, primarily Xanthomonas species, affecting various crops, including rice, beans, and potatoes. ",
        symptoms:
            "Bacterial leaf blight is often first noticed in fields as brown areas about 3 to 4 feet in diameter. Leaf symptoms appear as irregular brown water-soaked spots surrounded by a yellow halo, often beginning on the leaf margins. Spots grow together and result in leaf death and dark brown streaks develop on leaf petioles. ",
        treatment:
            "It can be managed through practices such as using resistant varieties, crop rotation, sanitation, avoiding overhead irrigation, applying balanced fertilizers, using bactericides, and monitoring for early signs of infection.",
      ),
      LearnEntity(
        disease: diseases[3],
        description:
            "A canker is really a symptom of an infection by various fungal and bacterial organisms. The pathogen often enters the host through an injury or open wound. Once the pathogen enters the wound, it can spread under the bark.",
        symptoms:
            "Cankers are usually oval to elongate, but can vary considerably in size and shape. Typically, they appear as localized, sunken, slightly discolored or dark lesions on the bark of trunks and branches, or as injured areas on smaller twigs.",
        treatment:
            "Control includes removing diseased parts in dry weather; growing adapted or resistant varieties in warm well-drained fertile soil; avoiding overcrowding, overwatering, and mechanical wounds; treating bark and wood injuries promptly; controlling insect and rodent disease carriers; wrapping young trees to prevent sunscald; and keeping plants vigorous by the use of fertilizers.",
      ),
      LearnEntity(
        disease: diseases[4],
        description:
            "Downy mildew is a disease of the foliage, caused by a fungus-like (Oomycete) organism. It is spread from plant to plant by airborne spores. It is a disease of wet weather as infection is favoured by prolonged leaf wetness.",
        symptoms:
            "Downy mildew is often harder to recognize than powdery mildew, so watch for discolored blotches on the upper leaf surface that can be pale green, yellow, purple, or brown, sometimes with straight edges bordered by leaf veins (as in lettuce). On the underside, a mold-like growth corresponding to the upper blotch may appear white, gray, or purple, with visibility varying by plant type. Severely affected leaves may shrivel and turn brown or yellow and fall prematurely, while other plant parts like cauliflower curds and flower buds can also be impacted. In severe cases, plants may become stunted, lack vigor, and in some instances, die.",
        treatment:
            "To manage downy mildew, implement a combination of cultural and chemical practices: select resistant plant varieties, improve air circulation by spacing plants properly, and avoid overhead watering to keep foliage dry. Regularly remove and destroy infected plant debris, and practice crop rotation to reduce disease buildup in the soil. Apply fungicides containing active ingredients like chlorothalonil or metalaxyl at the first signs of infection, following label instructions. Additionally, monitor plants regularly for early symptoms to enable prompt intervention and minimize spread.",
      ),
      LearnEntity(
        disease: diseases[5],
        description:
            "Powdery mildew is a host-specific fungal disease of global occurrence. It is easily recognized by a powdery formation on plants. The disease can affect virtually all kinds of plants, including grasses, fruits, vines, vegetables, and grain crops.",
        symptoms:
            "Powdery mildew appears on leaves as white patches of fungal growth, initially forming on the lower surface. Under favorable conditions, these patches expand and merge, often covering the entire underside. Affected leaves may curl upwards at the edges, revealing the characteristic powdery fungal layer. Purple to reddish blotches can also develop, adding to the leaf discoloration, and tiny, round, black fungal structures called cleistothecia may appear on the underside, further indicating the disease.",
        treatment:
            "Effective powdery mildew management combines cultural practices, sanitation, scouting, resistance, and, if necessary, chemical control. Maintaining plant health through proper watering, fertilization, and spacing helps prevent mildew, while removing infected leaves and debris reduces spore spread. Regular scouting aids early detection, and choosing resistant plant varieties can minimize outbreaks. If chemical control is needed, various options, including biorational compounds (like neem oil), biological agents (such as *Trichoderma harzianum*), and traditional fungicides, can be used following label instructions for safe and effective application.",
      ),
      LearnEntity(
        disease: diseases[6],
        description:
            "The rusts are a group of fungal diseases affecting the aerial parts of plants. Leaves are affected most commonly, but rust can also be found occasionally on stems and even flowers and fruit.many rust diseases present as orange rust on plants in the form of spots, patches or raised blisters. Rust spots on leaves can also come in a variety of shades from bright yellow to dark brown. The colour of the rust spots can darken as the disease matures and the seasons change from spring through to autumn.",
        symptoms:
            "As well as rust-coloured spots, patches or blisters, plant rust disease symptoms can include jelly-like ‘cluster-cups’ which contain spores. Where the rust is severe in plants such as hollyhocks, the leaves wither and drop off. Where rust occurs on bean plants, the crop will likely be reduced.",
        treatment:
            "To manage rust, remove and destroy affected leaves and plant parts, and consider discarding severely infected plants to prevent further spread. Apply a suitable fungicide as directed, though no chemicals are approved for edible plants. For lawns, mow frequently, discard clippings, and improve air flow by trimming overhanging branches. In pear rust management, remove nearby juniper bushes, which may host rust fungi. To treat rust on roses, prune infected stems in spring and, if necessary, use a combined insecticide-fungicide, ensuring not to apply when flowers are present or when bees are active.",
      ),
      LearnEntity(
        disease: diseases[7],
        description:
            "Shot hole is a leaf disease that produces brown spots on plant foliage that eventually dry out, fall, and leave multiple holes in the leaf.",
        symptoms:
            "The disease starts as spots on tree leaves that gradually grow in size. The host tree will use natural defenses to halt the growth of the fungal spots. As a result, the spots turn brown, dry out, and eventually drop out, causing the leaf to be covered in holes.",
        treatment:
            "If a tree has shot hole disease, be sure to limit overhead tree watering—especially during wet weather periods—as any excess water on the foliage will promote the spread of the disease. In addition, prune trees to provide air circulation throughout the canopy. Without proper circulation, plants remain damp and moist, creating the ideal environment for the development and spread of shot hole disease. When leaf drop occurs in fall, rake infected leaves from the tree’s bed to discourage the disease from reinfecting next spring.",
      ),
      LearnEntity(
        disease: diseases[8],
        description:
            "Leaf spot is a common descriptive term applied to several diseases affecting the foliage of ornamentals and shade trees. The majority of leaf spots are caused by fungi, but some are caused by bacteria. Some insects also cause damage that appears like a leaf spot disease. ",
        symptoms:
            "The chief symptom of a leaf spot disease is spots on foliage. The spots will vary in size and color depending on the plant affected, the specific organism involved, and the stage of development. Spots are most often brownish but may be tan or black. Concentric rings or dark margins are often present. Fungal bodies may appear as black dots in the spots, either in rings or in a central cluster.",
        treatment:
            "Integrated pest management for leaf spot diseases includes several strategies. Many trees can tolerate leaf spots without significant harm, so drastic measures are rarely needed unless repeated defoliation occurs. Removing infected leaves and dead twigs helps reduce spore levels but won’t eliminate infection entirely. Keeping foliage dry through early morning watering or soaker hoses and ensuring good air circulation can limit disease spread. Maintaining plant health, especially by avoiding over-fertilization, strengthens resilience. Fungicides may be used in severe cases, ideally applied early in the season. If disease persists, consider replacing the plant with a more resistant variety.",
      ),
      LearnEntity(
        disease: diseases[9],
        description:
            "Sooty mold is a fungal disease that grows on plants and other surfaces covered by honeydew, a sticky substance created by certain insects. Sooty mold’s name comes from the dark threadlike growth (mycelium) of the fungi resembling a layer of soot.",
        symptoms:
            "Sooty mold is usually a black powdery coating that develops on leaves and twigs. Sometimes the black layer may be hard and stick tightly to the leaf. During spring rains, the black layer may flake off or peel away from part of the leaf, leaving healthy looking green areas with splotches of the black sooty mold.",
        treatment:
            "To treat sooty mold, start by controlling honeydew-producing insects like aphids, scale, and whiteflies using insecticidal soap or horticultural oils. Once the pests are managed, gently wash affected leaves to remove the mold and improve plant health. Pruning to increase air circulation can also help discourage mold growth. Fungicides are rarely needed if the insect source is effectively controlled.",
      ),
    ];

    return learn;
  }
}
