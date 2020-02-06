<?php

declare(strict_types=1);

namespace App\DataFixtures;

use App\Entity\Post;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;

final class PostFixtures extends Fixture
{
    public const ARBITRARY_NBR_POSTS = 10;

    public function load(ObjectManager $manager)
    {
        $faker = Factory::create();
        for ($i = 0; $i < self::ARBITRARY_NBR_POSTS; $i++) {
            $post = new Post();
            $post->setTitle($faker->sentence(3));
            $post->setContent($faker->paragraph(3));

            $manager->persist($post);
        }

        $manager->flush();
    }

}